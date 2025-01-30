extends InventoryMenu
class_name ShopInventoryMenu

enum SHOP_ACTIONS {Buy, Sell}

@onready var money = $Money
var shop_scenario = null
var shop:itemShop = null
var player:GameCharacter = null

# Called when the node enters the scene tree for the first time.
func _ready():
	slot_script = preload("res://Scripts/UI/ShopInventorySlot.gd")
	source_menu_state = "DialogueBox"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	self.visible = true
	_on_inventory_updated()
	close.grab_focus()

func _on_inventory_updated():
	var current_player = GameManager.current_player
	clear_grid(inv_grid)
	money.bbcode_text = "[center]Money: [color=#28ff00]%d[/color]"%current_player.money
	for i in current_inventory.size():
		update_slot(current_inventory[i], inv_grid.get_child(i))

func setup_slots(item, grid):
	var slot = slot_scene.instantiate()
	slot.set_script(slot_script)
	grid.add_child(slot)
	slot.shop_scenario = shop_scenario
	slot.buy_item.connect(_on_item_transaction)
	slot.sell_item.connect(_on_item_transaction)
	slot.discard_item.connect(_on_discard_item)
	slot.slot_type = null
	if item:
		slot.set_item(item)
	else:
		slot.set_empty()

func set_data(buyer:GameCharacter, seller:itemShop, shop_state:int):
	player = buyer
	shop = seller
	shop_scenario = shop_state
	while inv_grid.get_child_count() > 0:
		inv_grid.remove_child(inv_grid.get_child(0))
	match shop_scenario:
		SHOP_ACTIONS.Buy:
			current_inventory = seller.InventoryManager.inventory
		SHOP_ACTIONS.Sell:
			current_inventory = buyer.InventoryManager.inventory
	for item in current_inventory:
		setup_slots(item, inv_grid)

func _on_item_transaction(slot):
	var player_money = GameManager.current_player.money
	var recipient = null
	match slot.shop_scenario:
		SHOP_ACTIONS.Buy:
			if player_money < slot.item.price:
				return
			GameManager.current_player.add_money(-slot.item.price)
			recipient = player
		SHOP_ACTIONS.Sell:
			GameManager.current_player.add_money(slot.item.price/2)
			recipient = shop
	recipient.InventoryManager.add_item(slot.item)
	slot.discard_item.emit()
	GameManager.add_points(GameManager.current_player.name, "shopping_done")
	_on_inventory_updated()

func _on_close_pressed():
	reset_state.emit()
	DialogueManager.text_vars["Speaker"] = shop.shopkeeper.info.name
	await DialogueManager.run_dialogue("shop_follow-up")
	var response = await DialogueManager.option_selected
	match response:
		"buy":
			shop.active_inventory = shop.InventoryManager.inventory
			await shop.open(ShopInventoryMenu.SHOP_ACTIONS.Buy)
		"sell":
			shop.active_inventory = GameManager.current_player.InventoryManager.inventory
			await shop.open(ShopInventoryMenu.SHOP_ACTIONS.Sell)
		"fight":
			var shopkeeper = shop.get_node("Shopkeeper")
			var battler_list = [shopkeeper]
			battler_list.append_array(GameManager.current_space.occupants)
			BattleManager.enterBattle(battler_list)
		"end":
			player = null
			shop = null
			GameManager.continue_game.emit()
