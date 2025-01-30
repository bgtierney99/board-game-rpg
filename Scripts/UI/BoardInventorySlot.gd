extends InventorySlot
class_name BoardInventorySlot

signal pet_companion(slot)

func setup_panel_buttons(slot_item: lootData):
	#if it has an item type, it can be equipped
	if slot_item.item_type:
		#only equipment slots have slot types
		if slot_type:
			match slot_item.item_type:
				"Companion":
					add_usage_button("Pet", pet_companion)
			add_usage_button("Unequip", unequip_item)
		#the rest of the inventory doesn't have slot types
		else:
			add_usage_button("Equip", equip_item)
	#without an item type, it can't be equipped, only used.
	else:
		add_usage_button("Use", use_item)
	add_usage_button("Move", move_item)
	add_usage_button("Discard", discard_item)
