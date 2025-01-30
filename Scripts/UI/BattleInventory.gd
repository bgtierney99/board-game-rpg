extends InventoryMenu
class_name BattleInventoryMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	slot_script = preload("res://Scripts/UI/BattleInventorySlot.gd")
	source_menu_state = "BattleMenu"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_inventory_updated():
	var current_player = GameManager.current_player
	clear_grid(inv_grid)
	current_inventory = current_player.InventoryManager.filter_items("Consumable")
	#inventory
	for i in current_inventory.size():
		update_slot(current_inventory[i], inv_grid.get_child(i))
		
func setup_slots(item, grid):
	var slot = slot_scene.instantiate()
	slot.set_script(slot_script)
	grid.add_child(slot)
	slot.use_item.connect(_on_use_item)
	slot.slot_type = null
	if item:
		slot.set_item(item)
		print("Setting %s in %s"%[item.name, slot])
	else:
		slot.set_empty()
