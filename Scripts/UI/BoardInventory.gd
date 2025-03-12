extends InventoryMenu
class_name BoardInventoryMenu

@onready var equip_grid = $EquipGrid
@onready var stats = $Stats
@onready var money = $Money

# Called when the node enters the scene tree for the first time.
func _ready():
	slot_script = preload("res://Scripts/UI/BoardInventorySlot.gd")
	source_menu_state = "PlayerActions"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	self.visible = true
	var current_player = GameManager.current_player
	current_inventory = current_player.InventoryManager.inventory
	current_equipment = current_player.equipment
	if inv_grid.get_child_count() == 0:
		for item in current_inventory:
			setup_slots(item, inv_grid)
	if equip_grid.get_child_count() == 0:
		for i in current_equipment.keys().size():
			var key = current_equipment.keys()[i]
			setup_slots(current_equipment[key], equip_grid)
			equip_grid.get_children()[i].slot_type = key
	_on_inventory_updated()
	close.grab_focus()

func setup_slots(item, grid):
	var slot = InventorySlot.new_slot()
	slot.set_script(slot_script)
	grid.add_child(slot)
	slot.pet_companion.connect(_on_pet_companion)
	slot.use_item.connect(_on_use_item)
	slot.equip_item.connect(_on_equip_item)
	slot.unequip_item.connect(_on_unequip_item)
	slot.move_item.connect(_on_move_item)
	slot.discard_item.connect(_on_discard_item)
	slot.item_button.pressed.connect(manage_slot_press.bind(slot))
	slot.slot_type = null
	if item:
		slot.set_item(item)
	else:
		slot.set_empty()

func _on_pet_companion(slot):
	print("%s gave %s some pets. %s enjoyed that."%[GameManager.current_player.name, slot.item.name, slot.item.name])
	#TODO: replace this print statement with a pet animation from the player and a reaction animation from the companion

func _on_unequip_item(e_slot):
	var inv_index = current_inventory.find(null)
	current_inventory[inv_index] = e_slot.item
	current_equipment[e_slot.slot_type] = null
	GameManager.current_player.update_stats()
	_on_inventory_updated()

func _on_equip_item(slot):
	#find the correct equipment slot that the item belongs in
	var temp_item = current_equipment[slot.item.item_type]
	current_equipment[slot.item.item_type] = slot.item
	current_inventory[inv_grid.get_children().find(slot)] = temp_item
	GameManager.current_player.update_stats()
	_on_inventory_updated()

func _on_inventory_updated():
	if UIManager.state == self:
		self.visible = true
	var current_player = GameManager.current_player
	clear_grid(inv_grid)
	clear_grid(equip_grid)
	#stats
	var stat_text = ""
	for stat in ["HP", "Attack", "Defense", "Speed"]:
		var stat_data = [stat,current_player.info.base_stats[stat],current_player.final_stats[stat]]
		stat_text += "[center]%s: %d[color=#b6fffe] > [/color][color=#28ff00]%d[/color]\n"%stat_data
	var max_spaces = clampi(GameManager.max_spaces+current_player.get_speed_offset(), 1, 999)
	stat_text += "Movement: [color=#28ff00]%d spaces[/color]"%max_spaces
	stats.bbcode_text = stat_text
	money.bbcode_text = "[center]Money: [color=#28ff00]%d[/color]"%current_player.money
	#inventory
	for i in range(current_inventory.size()):
		update_slot(current_inventory[i], inv_grid.get_child(i))
	#equipment
	for i in current_equipment.keys().size():
		var key = current_equipment.keys()[i]
		update_slot(current_equipment[key], equip_grid.get_child(i))

func _on_discard_item(slot):
	if slot.slot_type:
		current_equipment[slot.item.item_type] = null
	else:
		current_inventory[inv_grid.get_children().find(slot)] = null
	_on_inventory_updated()

func _on_move_item(slot):
	move_slot = slot
	
func manage_slot_press(slot):
	if move_slot:
		var focus_node = get_viewport().gui_get_focus_owner()
		place_held_item(slot)
		focus_node.grab_focus()
	else:
		slot.open_usage_panel()
	

func place_held_item(new_slot):
	if move_slot != null && (new_slot.slot_type == null or new_slot.slot_type == move_slot.item.item_type):
		var temp_item = new_slot.item
		#new location is an equipment slot
		if new_slot.slot_type:
			current_equipment[move_slot.item.item_type] = move_slot.item
		#new location is a regular slot
		else:
			current_inventory[inv_grid.get_children().find(new_slot)] = move_slot.item
		#original location is an equipment slot
		if move_slot.slot_type:
			current_equipment[move_slot.item.item_type] = temp_item
		#original location is a regular slot
		else:
			current_inventory[inv_grid.get_children().find(move_slot)] = temp_item
		move_slot = null
		GameManager.current_player.update_stats()
		_on_inventory_updated()
