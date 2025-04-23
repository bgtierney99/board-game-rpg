extends Control

@onready var random_image = preload("res://Assets/Art/Characters/Icons/random.png")
@export var grid: GridContainer
@export var back_button: Button
@export var confirm_button: Button
@export var character_image: TextureRect
@export var character_label: RichTextLabel
@export var player_label: RichTextLabel
@export var player_table: dataTable
var player_list:Array[Button]
var current_player = 0
var current_selection: Button

# Called when the node enters the scene tree for the first time.
func _ready():
	var character_button_scene = load("res://Scenes/UI/Menus/character_button.tscn")
	player_list.resize(GameManager.num_characters)
	player_label.text = "[center][b]Player %s"%(current_player+1)
	for character in player_table.table:
		var button = character_button_scene.instantiate()
		button.name = character.name
		button.character_info = character
		button.init_info()
		button.pressed.connect(set_selection.bind(button))
		button.set_character.connect(set_selection)
		button.show_details.connect(show_character_info)
		button.focus_next = get_path_to(confirm_button)
		grid.add_child(button)
	#random button
	var button = character_button_scene.instantiate()
	button.icon = random_image
	button.name = "Random"
	button.pressed.connect(random_selection.bind(button))
	button.focus_next = get_path_to(confirm_button)
	grid.add_child(button)
	grid.get_children().back().grab_focus()
	GameManager.scene_loaded.emit()

func random_selection(character_button):
	character_image.texture = random_image
	var character_data = Array()
	for i in range(5):
		character_data.append("???")
	set_character_label(character_data)
	current_selection = character_button
	player_list[current_player] = character_button
	back_button.focus_previous = get_path_to(character_button)
	back_button.focus_next = get_path_to(character_button)
	confirm_button.grab_focus()

func pick_random_character():
	var unselected = Array()
	for char in grid.get_children():
		if not char.selected and char.name != "Random":
			unselected.append(char)
	var character = unselected.pick_random()
	character.selected = true
	return character

func show_character_info(character_button):
	if character_button and not character_button.selected:
		var character = character_button.character_info
		character_image.texture = character_button.icon
		var character_data = [character.name, character.base_stats["HP"], character.base_stats["Attack"], character.base_stats["Defense"], character.base_stats["Speed"]]
		set_character_label(character_data)
	else:
		character_image.texture = null
		character_label.text = ""

func set_selection(character_button):
	if character_button:
		current_selection = character_button
		player_list[current_player] = character_button
		#back button should return to this selection naturally
		back_button.focus_previous = get_path_to(character_button)
		back_button.focus_next = get_path_to(character_button)
		confirm_button.grab_focus()

func set_character_label(character_data:Array):
	var char_text = "[center]Name: [color=#28ff00]%s[/color]\nHP: [color=#28ff00]%s[/color]\nAttack: [color=#28ff00]%s[/color]\nDefense: [color=#28ff00]%s[/color]\nSpeed: [color=#28ff00]%s[/color][/center]"
	character_label.text = char_text%character_data

#Go back to the board, resetting the view and letting the next player pick
func move_selection():
	player_label.text = "[center][b]Player %s"%(current_player+1)
	set_selection(null)

func _on_confirm_pressed():
	if current_selection and not current_selection.selected:
		$HBoxContainer/Confirm.set_disabled(true)
		player_list[current_player] = current_selection
		current_selection.selected = true
		current_selection.set_selected_number(current_player)
		if current_selection.name == "Random":
			current_selection.selected = false
		current_selection.grab_focus()
		#TODO: Add some sort of "P1", "P2", etc border around the selected character box
		if current_player == GameManager.num_characters-1:
			GameManager.player_data.clear()
			for p in player_list:
				if p.name == "Random":
					p = pick_random_character()
				GameManager.player_data.append(p.character_info)
			GameManager.change_scene("res://Scenes/board.tscn")
		else:
			current_player += 1
			move_selection()
		current_selection = null
		$HBoxContainer/Confirm.set_disabled(false)

func _on_back_pressed():
	$HBoxContainer/Back.set_disabled(true)
	if current_selection:
		set_selection(null)
	else:
		if current_player == 0:
			GameManager.change_scene("res://Scenes/main.tscn")
			return
		current_player -= 1
		player_list[current_player].selected = false
		player_list[current_player].set_selected_number(current_player)
		move_selection()
	player_list[current_player].grab_focus()
	$HBoxContainer/Back.set_disabled(false)
