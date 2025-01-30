extends InputComponent
class_name EnemyInputComponent

var action_seconds: float = 0.2
var goal_space
var space_weights:Dictionary = {}
var go_for_boss = false

func _ready():
	character = get_parent()

func find_goal_space(board_spaces:Array):
	goal_space = null
	var event_list = Array()
	var boss_space = board_spaces[event_list.find(eventData.EVENT_TYPE.boss)]
	if not go_for_boss:
		var choice_list = Array()
		for space in board_spaces:
			event_list.append(space.event_data.name)
		#low-HP players should prioritize healing at checkpoints
		if character.HPManager.health_percent <= 0.33:
			choice_list.append(event_list.find(eventData.EVENT_TYPE.checkpoint))
		#If a grave exists, rush to that
		if event_list.find(eventData.EVENT_TYPE.grave) != -1:
			choice_list.append(event_list.find(eventData.EVENT_TYPE.grave))
		#choose the type of space based on individual strategy
		match character.info.strategy:
			CharacterInfo.STRAT_TYPES.AGGRESSIVE:
				choice_list.append(event_list.find(eventData.EVENT_TYPE.encounter))
				#find spaces with players on them to chase them down
				for space in board_spaces:
					if not space.occupants.is_empty():
						choice_list.append(board_spaces.find(space))
			CharacterInfo.STRAT_TYPES.SCAVENGER:
				choice_list.append(event_list.find(eventData.EVENT_TYPE.prize))
				choice_list.append(event_list.find(eventData.EVENT_TYPE.companion))
		while choice_list.has(-1):
			choice_list.erase(-1)
		#isolate out any spaces that lead to the boss space to prevent going there too early
		for choice in choice_list:
			var space = board_spaces[choice]
			for neighbor in space.adjacent_spaces.values():
				if neighbor == boss_space:
					choice_list.erase(choice)
					break
		if choice_list.is_empty():
			choice_list.append(randi_range(1, board_spaces.size()-1))
		goal_space = board_spaces[choice_list.pick_random()]
	if go_for_boss:
		goal_space = boss_space
	
func pick_next_space(options):
	var chosen_space:BoardSpace = options.pick_random()
	if not goal_space:
		return chosen_space
	if options.has(goal_space):
		return goal_space
	#find the choice based on the lowest weight
	for space in options:
		if space_weights[space] < space_weights[chosen_space]:
			chosen_space = space
	return chosen_space
	
func find_shortest_path(board_spaces:Array):
	board_spaces.sort_custom(sort_distance_to_goal)
	calc_space_weights(goal_space, 0)
	
		
func calc_space_weights(space:BoardSpace, weight:int):
	if space_weights.has(space):
		return
	else:
		space_weights[space] = weight
		for option in space.adjacent_spaces.values():
			if option:
				calc_space_weights(option, weight+1)

func sort_distance_to_goal(a, b):
	if a.position.distance_to(goal_space.position) < b.position.distance_to(goal_space.position):
		return true
	return false
	
func trade_action(inventory_manager):
	var filtered_inv = inventory_manager.filter_items()
	return filtered_inv.pick_random()

func manage_inventory():
	#open the inventory menu and equip the strongest items available
	UIManager.change_state("BoardInventory")
	for equip_type in character.equipment.keys():
		var equip_val = 0
		if character.equipment[equip_type]:
			equip_val = character.equipment[equip_type].getValue()
		for item in character.InventoryManager.inventory:
			if item:
				var item_slot = UIManager.state.inv_grid.get_child(character.InventoryManager.inventory.find(item))
				if item.item_type == equip_type and item.getValue() > equip_val:
					UIManager.state._on_equip_item(item_slot)
	#if the character has full equipment, go for the boss. If not, don't.
	go_for_boss = !character.equipment.has(null)

func move_action():
	manage_inventory()
	#TODO: If HP is low, there is a teleporter in the inventory, and the player is more than 6 spaces away from a checkpoint, use the teleporter.
	UIManager.change_state("PlayerActions")
	UIManager.state._on_move_pressed()
	UIManager.state._on_roll_pressed()
	
func battle_action():
	#TODO: Do damage calculations on the three ranges to see when a low or high roll may be advantageous
	#Base these calculations off of median numbers, so 3, 7, and 11.
	var attack_list = [BattleManager.current_battle.high_roll, BattleManager.current_battle.full_roll, BattleManager.current_battle.low_roll]
	var callable = Callable(attack_list.pick_random())
	callable.call()

func dialogue_option_check():
	var dialogue_options = await DialogueManager.set_dialogue_options
	print("Dialogue Options: ", dialogue_options)
	if dialogue_options.is_empty():
		DialogueManager.option_selected.emit("end")
		return
	DialogueManager.option_selected.emit(dialogue_options.pick_random())
	
func dialogue_button_selection(button_list):
	return button_list.pick_random()

func pick_target(opponent_list):
	if character.info.smart_battler:
		var target = opponent_list[0]
		var damage_calc = GameManager.calc_damage(character.final_stats["Attack"], target.final_stats["Defense"], 6)
		for opponent in opponent_list:
			if opponent.HPManager.health_percent <= 0.33:
				return opponent
			var new_calc = GameManager.calc_damage(character.final_stats["Attack"], opponent.final_stats["Defense"], 6)
			if new_calc > damage_calc:
				damage_calc = new_calc
				target = opponent
		return target
	else:
		return opponent_list.pick_random()

#BATTLE LOGIC
#If a win can be guarenteed with a high roll, do that
#Assess the HP of the opponents the possible damage that can be dealt to you between the current turn and your next turn in the order
#If you can possibly lose before your next turn, do a low roll to guarentee going twice
#Do a high roll only if the outcome will result in the least amount of damage between turns
