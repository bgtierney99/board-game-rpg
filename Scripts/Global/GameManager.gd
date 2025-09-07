extends Node

#general purpose signals
signal add_items(target:InventoryComponent, item_list:Array[lootData]) #used for whenever items need to be added to a player's inventory
signal send_player_info(player_info_list:Array[CharacterInfo])
signal send_num_range(min, max)
signal send_num_result(value)
signal set_spawnpoint(player)
signal respawn_player(player)
signal continue_game
signal scene_loaded

#player action signals
signal action_done
signal hp_bar_done

var num_characters:int = 16
var num_players:int = 16
var movement_speed_threshold = 4
var max_spaces = 6
var boss_hp:int = 9999
var player_data:Array[CharacterInfo] = []
var player_list:Array[GameCharacter] = []
var current_player:GameCharacter = null
var current_space:BoardSpace = null
var space_check_subject:GameCharacter = null
var player_points = {}
var point_rewards = load("res://Resources/point_rewards.tres")
enum WORLD {SCIFI, STEAMPUNK, TAMER, TOON, BOARD}

func setDefaultValues():
	num_characters = 16
	num_players = 16
	player_data = []
	player_list = []
	current_player = null
	current_space = null
	space_check_subject = null
	player_points = {}

func unique_copy(arr: Array):
	var arr_copy = Array()
	for element in arr:
		arr_copy.append(element)
	return arr_copy

func get_table(table:String):
	return load("res://Resources/Tables/"+ table +".tres")

func rotate_player_toward_target(player, target_pos):
	var dir = player.global_position.direction_to(target_pos)
	var character_model = player.character_model
	var new_rotation = character_model.rotation
	new_rotation.y = lerp_angle(character_model.rotation.y, atan2(-dir.x, -dir.z), 1)
	var tween = create_tween()
	tween.tween_property(character_model, "rotation", new_rotation, 0.3).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func add_points(player_name, category):
	if not player_points[player_name].has(category):
		player_points[player_name][category] = 1
		return
	player_points[player_name][category] += 1
	
func calc_damage(attack_stat, defense_stat, damage_roll):
	var defense_calc:float = (40/float(30+(defense_stat)))
	var percent_calc:float = float((damage_roll-1)/5.5)
	return round(percent_calc*attack_stat*defense_calc)

func reset_to_main():
	print("Resetting game.")
	UIManager._on_reset_state()
	await GameManager.change_scene("res://Scenes/main.tscn")
	#get_tree().reload_current_scene()
	#NOTE: reload_current_scene() doesn't seem to work. Need to do some custom thing to reset the GameManager variables.
	setDefaultValues()

func win_game():
	#transition to the points reward screen
	change_scene("res://Scenes/UI/Menus/end_results.tscn")

func change_scene(new_scene:String):
	if not new_scene.contains(".tscn"):
		print("Not a valid scene file!")
		return
	var loading_screen = load("res://Scenes/UI/Menus/loading_screen.tscn").instantiate()
	add_child(loading_screen)
	await get_tree().create_timer(0).timeout
	get_tree().change_scene_to_file(new_scene)
	await scene_loaded
	remove_child(loading_screen)
	loading_screen.queue_free()
