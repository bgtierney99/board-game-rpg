extends MenuState
class_name InventoryMenu

@onready var inv_grid = $InvGrid
@onready var close = $Close
var move_slot
var current_inventory
var current_equipment
var slot_script = preload("res://Scripts/UI/InventorySlot.gd")
var source_menu_state = "PlayerActions"

# Called when the node enters the scene tree for the first time.
func _ready():
	for item in GameManager.current_player.InventoryManager.inventory:
		setup_slots(item, inv_grid)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	self.visible = true
	current_inventory = GameManager.current_player.InventoryManager.inventory
	if inv_grid.get_child_count() == 0:
		for item in current_inventory:
			setup_slots(item, inv_grid)
	_on_inventory_updated()
	close.grab_focus()

func setup_slots(item, grid):
	var slot = InventorySlot.new_slot()
	slot.set_script(slot_script)
	grid.add_child(slot)
	slot.use_item.connect(_on_use_item)
	slot.discard_item.connect(_on_discard_item)
	slot.slot_type = null
	if item:
		slot.set_item(item)
	else:
		slot.set_empty()

func update_slot(item, slot):
	if slot:
		if item:
			slot.set_item(item)
		else:
			slot.set_empty()

func _on_inventory_updated():
	clear_grid(inv_grid)
	for i in current_inventory.size():
		update_slot(current_inventory[i], inv_grid.get_child(i))

func clear_grid(grid):
	for slot in grid.get_children():
		slot.set_empty()

func _on_use_item(slot):
	slot.item.effect.effect(GameManager.current_player)
	GameManager.current_player.InventoryManager.remove_item(slot.item)
	_on_inventory_updated()
	if UIManager.state:
		UIManager.state.reset_state.emit()

func _on_discard_item(slot):
	if slot.slot_type:
		current_equipment[slot.item.item_type] = null
	else:
		current_inventory[inv_grid.get_children().find(slot)] = null
	_on_inventory_updated()

func _on_close_pressed():
	UIManager.change_state(source_menu_state)
