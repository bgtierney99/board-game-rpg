extends InventorySlot
class_name ShopInventorySlot

var shop_scenario:int

signal buy_item(slot)
signal sell_item(slot)

func setup_panel_buttons(_slot_item: lootData):
	match shop_scenario:
		ShopInventoryMenu.SHOP_ACTIONS.Buy:
			add_usage_button("Buy", buy_item)
		ShopInventoryMenu.SHOP_ACTIONS.Sell:
			add_usage_button("Sell", sell_item)
