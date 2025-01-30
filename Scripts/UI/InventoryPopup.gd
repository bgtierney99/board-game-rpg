extends Control
class_name InventoryPopup

@onready var inventory_panel = $InventoryPanel
@onready var grid_container = $InventoryPanel/MarginContainer/GridContainer
var inv_slot_scene = preload("res://Scenes/UI/Menus/inventory_slot.tscn")

signal inv_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_panel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_inventory(inventory:Array):
	if inventory.size() == 0:
		var inv_slot = inv_slot_scene.instantiate()
		grid_container.add_child(inv_slot)
		inv_slot.set_empty()
		inv_slot.item_button.pressed.connect(close_inventory)
	else:
		for item in inventory:
			var inv_slot = inv_slot_scene.instantiate()
			grid_container.add_child(inv_slot)
			inv_slot.set_item(item)
			inv_slot.item_button.pressed.connect(close_inventory)
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
	inv_closed.emit()
