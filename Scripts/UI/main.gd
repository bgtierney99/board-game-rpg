extends Control

@onready var go = $Go
@export var num_characters_group:ButtonGroup
@export var num_players_group:ButtonGroup

# Called when the node enters the scene tree for the first time.
func _ready():
	num_characters_group.pressed.connect(setupNumPlayersButtons)
	num_players_group.pressed.connect(setNumPlayers)
	for i in range(16):
		var num = CheckBox.new()
		num.text = str(i+1)
		num.toggle_mode = true
		num.button_group = num_characters_group
		$Options/NumCharacters/HBoxContainer.add_child(num)
	num_characters_group.get_buttons()[GameManager.num_characters-1].button_pressed = true
	go.grab_focus()
	num_players_group.get_buttons()[GameManager.num_players].button_pressed = true
	GameManager.scene_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generateBoxes(button_box, button_group):
	for i in range(GameManager.num_characters+1):
		var num = CheckBox.new()
		num.text = str(i)
		num.toggle_mode = true
		num.button_group = button_group
		button_box.add_child(num)
	button_group.get_buttons()[GameManager.num_characters].button_pressed = true

#run this when num characters is set
func setupNumPlayersButtons(current_button):
	GameManager.num_characters = int(current_button.text)
	var button_box = $Options/NumPlayers/HBoxContainer
	for child in button_box.get_children():
		child.button_group = null
		button_box.remove_child(child)
		child.queue_free()
	if GameManager.num_players > GameManager.num_characters:
		GameManager.num_players = GameManager.num_characters
	generateBoxes(button_box, num_players_group)
	num_players_group.get_buttons()[GameManager.num_players].button_pressed = true

	
func setNumPlayers(button):
	GameManager.num_players = int(button.text)

func _on_go_pressed():
	randomize()
	await GameManager.change_scene("res://Scenes/UI/Menus/character_selection.tscn")
