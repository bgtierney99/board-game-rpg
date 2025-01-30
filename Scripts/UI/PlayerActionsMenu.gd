extends MenuState

signal move_to_num

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	visible = true
	$Move.grab_focus()

func _on_move_pressed():
	move_to_num.emit()
	UIManager.change_state("RollMenu")

func _on_inventory_pressed():
	UIManager.change_state("BoardInventory")

func _on_map_pressed():
	UIManager.state_list["MapMenu"].source_menu = UIManager.state.get_name()
	UIManager.change_state("MapMenu")
