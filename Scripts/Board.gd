extends Node3D

var current_player: GameCharacter
var current_round = 1

@export var space_distance_threshold:float = 2
@export var space_height_threshold:float = 1.5
@export var main_camera: Camera3D
@export var overhead_camera: Camera3D
@export var test_space:eventData
@onready var round_text = $RoundText
@onready var death_text = $DeathText
@onready var starting_space = $BossHub/Start
@onready var spaces = $BossHub/Spaces
@onready var item_pool = GameManager.get_table("weighted_item_pool").table.duplicate()
@onready var event_pool = GameManager.get_table("weighted_event_pool").table.duplicate()

var all_spaces:Array
var boardData:Dictionary[String, Dictionary]

# Called when the node enters the scene tree for the first time.
func _ready():
	$SavingLabel.visible = false
	round_text.visible = false
	death_text.visible = false
	#randomize board space effects if they don't have a static one set
	space_setup()
	starting_space.adjacent_spaces["Forward"] = spaces.get_child(0)
	#connect signals
	UIManager.state_list["PlayerActions"].move_to_num.connect(transition_cameras.bind($Disk.camera))
	UIManager.state_list["RollMenu"].back_to_player.connect(transition_cameras.bind(main_camera))
	GameManager.send_num_range.connect(spin_disk)
	GameManager.send_num_result.connect(manage_result)
	GameManager.respawn_player.connect(respawn)
	#setup players
	await player_setup(GameManager.player_data)
	GameManager.scene_loaded.emit()

func assemble_board_locations():
	var chunk_list = []
	var criteria_table_settings = load("res://Resources/Tables/Board Generation/board_gen_criteria.tres").table
	var criteria_table_worlds = load("res://Resources/Tables/Board Generation/board_gen_criteria_worlds.tres").table
	criteria_table_settings.shuffle()
	var location_chunks = $Chunks.get_children()
	#Prioritize areas from each world, then specific settings/types of locations
	for criteria_table in [criteria_table_worlds, criteria_table_settings]:
		for criteria in criteria_table:
			#For each entry in the current criteria, check if any have already been selected
			var selected_entry = criteria.table.pick_random()
			if not chunk_list.has(selected_entry):
				#Assuming the iteration continues, pick a board location from the list and assign it to the current chunk
				chunk_list.append(selected_entry)
				if chunk_list.size() == location_chunks.size():
					break
	#if all chunks are not filled after the criteria is satisfied, add random board locations to the remaining chunks
	var chunk_num = location_chunks.size()
	if chunk_list.size() < chunk_num:
		var all_locations_table = []
		for world in criteria_table_worlds:
			for location in world.table:
				all_locations_table.append(location)
		for location in all_locations_table:
			if chunk_list.has(location):
				all_locations_table.erase(location)
		while chunk_list.size() < location_chunks.size():
			chunk_list.append(all_locations_table.pick_random())
			if chunk_list.size() == location_chunks.size():
				break
	#Instantiate all the new areas into the world
	for i in range(0, $Chunks.get_child_count()):
		location_chunks[i].add_child(chunk_list[i].scene.instantiate())
		

func generate_spaces():
	var space_list = spaces.get_children()
	var space_scene = preload("res://Scenes/Objects/space.tscn")
	var space_positions = Array()
	var space_dict := {}
	#add initial spaces into list
	for space in space_list:
		var space_pos = space.position
		space_positions.append(space_pos)
		space_dict[space_pos] = space
		for other_space in space_list:
			#get position for new in-between spaces
			var other_space_pos = other_space.position
			if other_space_pos == space_pos:
				continue
			var diff = other_space_pos-space_pos
			#check that the spaces are lined up
			if diff.x == 0 or diff.z == 0:
				var num_spaces = space_pos.distance_to(other_space_pos)/space_distance_threshold-1
				for i in range(num_spaces):
					var new_space_pos = space_pos+((space_distance_threshold*diff.normalized())*(i+1))
					space_dict[new_space_pos] = null
	#generate spaces
	for space_pos in space_dict.keys():
		if not space_positions.has(space_pos):
			var new_space = space_scene.instantiate()
			spaces.add_child(new_space)
			new_space.add_to_group("Spaces")
			new_space.position = space_pos
			space_list.append(new_space)
	return space_list

func link_spaces(space_list: Array):
	#link spaces together
	for space in space_list:
		all_spaces.append(space)
		for other_space in space_list:
			if other_space != space:
				var dist_to_space = space.position.distance_to(other_space.position)
				#adjacent spaces can't be more than the threshold away or too high
				if dist_to_space == space_distance_threshold and other_space.position.y <= space.position.y+space_height_threshold:
					if other_space.position.x > space.position.x: space.adjacent_spaces["Right"] = other_space
					elif other_space.position.x < space.position.x: space.adjacent_spaces["Left"] = other_space
					elif other_space.position.z > space.position.z: space.adjacent_spaces["Back"] = other_space
					elif other_space.position.z < space.position.z: space.adjacent_spaces["Forward"] = other_space
					
func set_space_data(space: BoardSpace):
	if not space.event_data:
		var new_event:eventData = load("res://Resources/Events/event_basic.tres")
		#if a space has more than two options to pick from, don't let special spaces spawn there
		var option_count = 0
		for option in space.adjacent_spaces.values():
			if option != null:
				option_count += 1
		if option_count <= 2:
			if test_space:
				new_event = test_space
			else:
				new_event = get_random_space()
		space.event_data = new_event
		#populate prize spaces
		if space.event_data.name == eventData.EVENT_TYPE.prize:
			#checking for this allows for cases where I want to have a prize space with a pre-filled container in a static place
			if not space.has_node("container"):
				#get contents to put in a container
				var item_list = set_prizes()
				#create a container to put the contents into
				space.ActionManager.setup_container(item_list)
	space.set_event_data()
	GameManager.set_spawnpoint.connect(set_spawn)
	space.occupants_changed.connect(position_players.bind(space))
	
func set_prizes():
	var item_list:Array[lootData] = []
	#get item pool weight sum
	var total_weight = 0
	for stack in item_pool:
		if stack["count"] > 0:
			total_weight += stack["weight"]
	#generate items
	for i in randi_range(1, 5):
		var rand_weight = randi_range(0, total_weight)
		for stack in item_pool:
			if stack["count"] == 0 or rand_weight >= stack["weight"]:
				continue
			item_list.append(stack["resource"])
			stack["count"] -= 1
	return item_list

func get_random_space():
	var total_weight = 0
	var current_total_weight = 0
	for stack in event_pool:
		total_weight += stack["weight"]
	var rand_weight = randi_range(0, total_weight)
	for stack in event_pool:
		current_total_weight += stack["weight"]
		if rand_weight <= current_total_weight:
			return stack["resource"]

func space_setup():
	assemble_board_locations()
	#get all spaces
	var space_list = spaces.get_children().duplicate()
	for chunk in $Chunks.get_children():
		space_list += chunk.get_child(0).get_node("Spaces").get_children()
	link_spaces(space_list)
	for space in space_list:
		set_space_data(space)

func player_setup(info_list):
	var player_scene = preload("res://Scenes/Characters/character.tscn")
	for i in range(GameManager.num_characters):
		var player = player_scene.instantiate()
		if not info_list.is_empty():
			player.info = info_list[i]
		player.add_to_group("Players")
		player.name = player.info.name
		boardData[player.get_name()] = {"Space": starting_space, "Spawnpoint": starting_space}
		#player.position = starting_space.position
		await starting_space.add_player(player)
		#separate human players from Enemy players
		if i < GameManager.num_players:
			player.InputManager = PlayerInputComponent.new()
			player.InputManager.index = i
		player.InputManager.character = player
		GameManager.player_list.append(player)
		$Players.add_child(player)
		player.health_bar.visible = false
		GameManager.player_points[player.name] = {}
	position_players(starting_space)
	current_player = GameManager.player_list[0]
	GameManager.current_player = current_player
	#boss setup
	var boss = get_tree().get_nodes_in_group("Boss")[0]
	GameManager.boss_hp = boss.final_stats["HP"]
	#add player data to top info
	$PlayerInfo.z_index = -10
	$PlayerInfo.init_info()
	$PlayerInfo.setup_boss_health(boss)
	main_camera.make_current()
	do_round(1)

func move_camera(subject):
	main_camera.reparent(subject)
	overhead_camera.reparent(subject)
	var camera_tween = create_tween().set_parallel(true)
	camera_tween.tween_property(main_camera, "global_position", subject.global_position+Vector3(0, 3, 5), 0.5)
	overhead_camera.global_position = subject.global_position+Vector3(0, 7, 0)
	await camera_tween.finished
	
func transition_cameras(cam_2:Camera3D):
	var cam_1 = get_viewport().get_camera_3d()
	var cam_pos = cam_1.global_position
	var cam_rot = cam_1.rotation
	var tween = get_tree().create_tween()
	tween.tween_property(cam_1, "global_position", cam_2.global_position, 0.3)
	tween.parallel().tween_property(cam_1, "rotation", cam_2.rotation, 0.3)
	await tween.finished
	cam_2.make_current()
	cam_1.global_position = cam_pos
	cam_1.rotation = cam_rot

func manage_result(value):
	await transition_cameras(main_camera)
	if current_player.in_battle:
		BattleManager.current_battle.set_attack(value, 2)
	else:
		move_spaces(value)

#reset for the next player
func start_turn(player):
	UIManager._on_reset_state()
	current_player = player
	GameManager.current_player = current_player
	$PlayerInfo.updateStatus()
	GameManager.current_space = boardData[GameManager.current_player.get_name()]["Space"]
	#UIManager.change_state(null)
	await move_camera(player)
	#resume battle if the player is one of the battlers
	if player.in_battle:
		#find the battle the player is in and resume it
		for battle in BattleManager.battle_list:
			if battle.battler_list.has(player):
				BattleManager.current_battle = battle
				break
		BattleManager.current_battle.start_set()
		await BattleManager.set_finished
	else:
		#player can't move this turn because of some space event
		if GameManager.current_player.turn_count > 0:
			await GameManager.current_space.event()
		else:
			UIManager.change_state("PlayerActions")
			if player.InputManager is EnemyInputComponent:
				player.InputManager.find_goal_space(all_spaces)
				player.InputManager.find_shortest_path(all_spaces)
				player.InputManager.move_action()
			await GameManager.action_done
	end_turn()

func end_turn():
	if not current_player.in_battle:
		current_player.use_equipment_effects()
	#check if any players need to respawn
	for player in GameManager.player_list:
		if player.is_dead:
			await killPlayer(player)
			await respawn(player)
	#shift over to next player
	UIManager.state_list["RollMenu"].back_to_player.disconnect(move_camera)
	var next_index = (GameManager.player_list.find(current_player)+1)%GameManager.player_list.size()
	current_player = GameManager.player_list[next_index]
	GameManager.current_player = current_player
	UIManager._on_reset_state()
	#next turn cycle
	if next_index == 0:
		current_round += 1
		await SaveManager.save()
		do_round(current_round)
	#next player in the order
	else:
		start_turn(current_player)

func move_on_board(character, space):
	var new_pos = space.position
	#movement logic
	var pos_diff = Vector3.ZERO
	pos_diff.x = (character.position.x + new_pos.x)/2
	pos_diff.z = (character.position.z + new_pos.z)/2
	GameManager.rotate_player_toward_target(character, new_pos)
	#movement action
	var tween = create_tween()
	tween.parallel().tween_property(character, "position", Vector3(pos_diff.x, new_pos.y+1.5, pos_diff.z), 0.3).set_ease(Tween.EASE_OUT)
	tween.tween_property(character, "position", new_pos, 0.3).set_ease(Tween.EASE_IN)
	character.character_model.rotation.x = space.rotation.x
	character.character_model.rotation.z = space.rotation.z
	await tween.finished

func position_players(space):
	if space.occupants.size() > 0:
		var tween = create_tween().set_parallel(true)
		for i in range(space.occupants.size()):
			var rollover:int = space.points.get_child_count()+1
			tween.tween_property(space.occupants[i], "global_position", space.global_position+space.points.get_child(i).global_position, 0.25)
		await tween.finished

func pick_direction(current_space, space_choices):
	var options = space_choices.values()
	while options.has(null):
		options.erase(null)
	#Dead end. No new spaces to hit. Stop here.
	if options.size() == 0:
		return null
	elif options.size() == 1:
		return options[0]
	else:
		if current_player.InputManager is EnemyInputComponent:
			return current_player.InputManager.pick_next_space(options)
		var prev_cam = get_viewport().get_camera_3d()
		await transition_cameras(overhead_camera)
		$PlayerInfo.visible = false
		current_space.show_direction_buttons(space_choices)
		#var result = await current_space.direction_selection_dialogue(space_choices)
		var result = await current_space.space_picked
		await transition_cameras(prev_cam)
		$PlayerInfo.visible = true
		return result

func move_spaces(num_spaces):
	await move_camera(current_player)
	var previous_space
	var current_space = boardData[current_player.get_name()]["Space"]
	await current_space.remove_player(current_player)
	var new_space
	#show a number above the player for the number of spaces they have to move
	var move_counter = Label3D.new()
	current_player.add_child(move_counter)
	move_counter.global_position = current_player.global_position+Vector3(0, 1.5, 0)
	move_counter.text = "Moves Left: %d"%num_spaces
	for i in num_spaces:
		var space_choices:Dictionary = current_space.adjacent_spaces.duplicate(true)
		var old_key = space_choices.find_key(previous_space)
		space_choices[old_key] = null
		new_space = await pick_direction(current_space, space_choices)
		#Dead end
		if not new_space:
			move_counter.text = "Dead end!"
			break
		#Adjusting for next iteration
		previous_space = current_space
		current_space = new_space
		var transform_new:Transform3D
		#move player to new space
		await move_on_board(current_player, new_space)
		move_counter.text = "Moves Left: %d"%(num_spaces-(i+1))
		GameManager.add_points(current_player.name, "spaces_traveled")
	if not new_space:
		move_counter.text = "Dead end!"
	await get_tree().create_timer(0.1).timeout
	current_player.remove_child(move_counter)
	move_counter.queue_free()
	await boardData[current_player.get_name()]["Space"].remove_player(current_player)
	boardData[current_player.get_name()]["Space"] = current_space
	GameManager.current_space = current_space
	await current_space.add_player(current_player)
	await current_space.event()
	if current_space.occupants.size() > 1:
			await current_space.interaction_check()
	#a battle was started after movement
	if current_player.in_battle:
		await BattleManager.set_finished
	#trade happening
	if TradeManager.trade_active:
		await TradeManager.trade_finished
	GameManager.action_done.emit()

func do_round(round_num):
	$PlayerInfo.updateStatus()
	await move_camera(current_player)
	round_text.text = "Round %s!"%round_num
	round_text.visible = true
	await get_tree().create_timer(1).timeout
	death_text.text = ""
	round_text.visible = false
	#Some kind of logic keeping track of reaching specific turns can go here
	match round_num:
		1:
			await move_camera(get_tree().get_nodes_in_group("Boss")[0])
			await DialogueManager.run_dialogue("intro_speech_boss")
		7:
			print("Round 7 reached!")
	start_turn(current_player)

func spin_disk(min, max):
	max = clampi(max+current_player.get_speed_offset(), 1, 999)
	#max = 1
	await $Disk.spin(min, max)

func set_spawn(player, space):
	boardData[player.get_name()]["Spawnpoint"] = space
	
func replace_space(event_data):
	#find the spaces that can be set
	var empty_spaces = Array()
	for space in all_spaces:
		var option_count = 0
		for option in space.adjacent_spaces.values():
			if option != null:
				option_count += 1
		if space.event_data.name == eventData.EVENT_TYPE.basic and option_count <= 3:
			empty_spaces.append(space)
	#pick a random one from that list of spaces
	var new_space
	if empty_spaces.size() > 0:
		new_space = empty_spaces.pick_random()
		new_space.event_data = event_data
	else:
		print("Nowhere to place new space!")
	return new_space

func set_grave_space(player):
	var grave_space = replace_space(load("res://Resources/Events/event_grave.tres"))
	if grave_space:
		for child in grave_space.get_children():
			if child is itemContainer:
				child.loot_owner = player.info.name
				print("Container is owned by ", child.loot_owner)
		var grave_inventory = GameManager.unique_copy(player.InventoryManager.inventory)
		grave_inventory.append_array(player.equipment.values())
		grave_space.ActionManager.setup_container(grave_inventory)
		player.InventoryManager.clear()
		for key in player.equipment.keys():
			player.equipment[key] = null
		player.update_stats()
		await move_camera(grave_space)
		await DialogueManager.run_dialogue("player_grave")

func killPlayer(player):
	await move_camera(GameManager.current_space)
	death_text.text = "%s\ndied!"%player.name
	death_text.visible = true
	await get_tree().create_timer(1).timeout
	death_text.text = ""
	death_text.visible = false
	var current_equipment = player.equipment.values().duplicate(true)
	while current_equipment.has(null):
		current_equipment.erase(null)
	if player.InventoryManager.get_item_count() > 0 or current_equipment.size() > 0:
		await set_grave_space(player)
	else:
		await DialogueManager.run_dialogue("no_grave")
	player.is_dead = false
	GameManager.add_points(player.name, "deaths")

func respawn(player):
	player.visible = false
	await move_camera(boardData[player.get_name()]["Space"])
	await boardData[player.get_name()]["Space"].remove_player(player)
	boardData[player.get_name()]["Space"] = boardData[player.get_name()]["Spawnpoint"]
	var respawn_space = boardData[player.get_name()]["Space"]
	await respawn_space.add_player(player)
	player.position = respawn_space.position
	#have player rotate toward the first available exit space
	for val in respawn_space.adjacent_spaces.values():
		if val != null:
			GameManager.rotate_player_toward_target(player, val.position)
	await boardData[player.get_name()]["Space"].event()
	player.visible = true
	await move_camera(player)
