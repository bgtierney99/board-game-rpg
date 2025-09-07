extends Control
class_name InventoryPopup

@onready var inventory_panel = $InventoryPanel
@onready var grid_container = $InventoryPanel/MarginContainer/GridContainer

signal inv_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_panel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_inventory(inventory:Array):
	if inventory.size() == 0:
		var slot = InventorySlot.new_slot()
		grid_container.add_child(slot)
		slot.set_empty()
		slot.item_button.pressed.connect(close_inventory)
	else:
		for item in inventory:
			var slot = InventorySlot.new_slot()
			grid_container.add_child(slot)
			slot.set_item(item)
			slot.item_button.pressed.connect(close_inventory)
	grid_container.get_child(0).item_button.grab_focus()
	grid_container.get_child(0).details_panel.visible = false
	inventory_panel.visible = true
	if GameManager.current_player.InputManager is EnemyInputComponent:
		await get_tree().create_timer(2).timeout
	else:
		await inv_closed
	GameManager.continue_game.emit()

func close_inventory():
	inventory_panel.visible = false
	#clear out the child slots
	for child in grid_container.get_children():
		grid_container.remove_child(child)
		child.queue_free()
	inv_closed.emit()
