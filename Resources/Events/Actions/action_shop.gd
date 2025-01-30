extends EventAction
class_name action_shop

func setup_shop(inventory):
	print("No shop found. Setting one up!")
	var shop = load("res://Scenes/Objects/shop.tscn").instantiate()
	shop.InventoryManager.inventory.resize(inventory.size())
	shop.InventoryManager.add_items(inventory)
	shop.name = "Shop"
	space.add_child(shop)
	space.place_object(shop)

func action(player:GameCharacter):
	var shop = space.get_node("Shop")
	if shop.shopkeeper:
		GameManager.rotate_player_toward_target(player, shop.shopkeeper.global_position)
		DialogueManager.text_vars["Speaker"] = shop.shopkeeper.info.name
		await DialogueManager.run_dialogue("shop_intro")
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
				battler_list.append_array(space.occupants)
				BattleManager.enterBattle(battler_list)
			"end":
				GameManager.continue_game.emit()
