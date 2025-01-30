extends MenuState

signal back_to_player

var source_menu = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	visible = true
	$HBoxContainer/Back.grab_focus()
	#TODO: Move camera to an overhead view of the current space

func _on_back_pressed():
	back_to_player.emit()
	UIManager.change_state(source_menu)
