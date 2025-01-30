extends InventorySlot
class_name BattleInventorySlot

func setup_panel_buttons(_slot_item: lootData):
	add_usage_button("Use", use_item)
