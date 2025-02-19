extends MenuState
class_name TradeMenu

var player_inventories = []
@onready var grids:Array = $Grids.get_children()
#var slot_script = preload("res://Scripts/UI/InventorySlot.gd")
var source_menu_state = "PlayerActions"
var current_trade_index = 0
@onready var back_button = $HBoxContainer/Back
@onready var trade_button = $HBoxContainer/Trade
var trade_slots:Array[InventorySlot] = []
var selected_slots:Array[InventorySlot] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	trade_slots = [$TradeSlot1, $TradeSlot2]
	for slot in trade_slots:
		slot.item_button.focus_mode = 0
	selected_slots.resize(2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	self.visible = true
	for trader in TradeManager.trade_players:
		player_inventories.append(trader.InventoryManager.inventory)
	for i in range(grids.size()):
		if grids[i].get_child_count() == 0:
			for item in player_inventories[i]:
				setup_slot(item, grids[i])
	update_inventories()
	trade_slots[0].set_empty()
	trade_slots[1].set_empty()
	current_trade_index = 0
	grids[0].get_child(0).item_button.grab_focus()

func setup_slot(item, grid):
	var slot = InventorySlot.new_slot()
	slot.size = slot.size/1.5
	grid.add_child(slot)
	slot.slot_type = null
	if item:
		slot.set_item(item)
		slot.item_button.pressed.connect(set_trade_item.bind(slot))
	else:
		slot.set_empty()

func update_slot(slot, item):
	if item:
		slot.set_empty()
		slot.set_item(item)
	else:
		slot.set_empty()

func update_inventories():
	for i in range(grids.size()):
		clear_grid(grids[i])
		for j in player_inventories[i].size():
			update_slot(grids[i].get_child(j), player_inventories[i][j])

func clear_grid(grid):
	for slot in grid.get_children():
		slot.set_empty()
		
func set_trade_item(slot):
	selected_slots[current_trade_index] = slot
	if slot:
		update_slot(trade_slots[current_trade_index], slot.item)
		if slot.get_parent() == grids[current_trade_index]:
			if slot.item:
				if current_trade_index == 0:
					grids[1].get_child(0).item_button.grab_focus()
				elif current_trade_index == 1:
					trade_button.grab_focus()
				if current_trade_index < 1:
					current_trade_index += 1
					if TradeManager.trade_players[1].InputManager is EnemyInputComponent:
						var item = TradeManager.trade_players[1].InputManager.trade_action(TradeManager.trade_players[1].InventoryManager)
						set_trade_item(grids[1].get_child(player_inventories[1].find(item)))
						_on_trade_pressed()
	else:
		update_slot(trade_slots[current_trade_index], null)

func _on_back_pressed():
	set_trade_item(null)
	grids[current_trade_index].get_child(0).item_button.grab_focus()
	if current_trade_index != 0:
		current_trade_index -= 1

func _on_trade_pressed():
	if not selected_slots.has(null):
		do_trade()

func do_trade():
	for i in player_inventories.size():
		update_slot(selected_slots[i], trade_slots[(i+1)%2].item)
		player_inventories[i][grids[i].get_children().find(selected_slots[i])] = trade_slots[(i+1)%2].item
	await get_tree().create_timer(0.2).timeout
	TradeManager.trade_finished.emit()
