extends MenuState

signal do_numbers(min, max)
signal back_to_player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	visible = true
	$HBoxContainer/Roll.grab_focus()

func _on_roll_pressed():
	GameManager.send_num_range.emit(1, GameManager.max_spaces)
	reset_state.emit()


func _on_back_pressed():
	back_to_player.emit()
	UIManager.change_state("PlayerActions")
