extends EventAction
class_name action_prize

func setup_container(inventory):
	var container = load("res://Scenes/Objects/container.tscn").instantiate()
	container.InventoryManager.inventory.resize(inventory.size())
	container.InventoryManager.add_items(inventory)
	container.name = "container"
	space.add_child(container)
	space.place_object(container)

func action(player:GameCharacter):
	await DialogueManager.run_dialogue("prize_found")
	var response = await DialogueManager.option_selected
	match response:
		"open":
			var container:itemContainer = space.get_node("container")
			GameManager.rotate_player_toward_target(player, container.global_position)
			var new_items = container.open()
			await GameManager.continue_game
			if new_items.is_empty():
				var rand_chance = randf()
				#percentage chance that empty containers damage the player
				if rand_chance <= 0.2:
					var damage = GameManager.calc_damage(30, player.final_stats["Defense"], randi_range(1, 12))
					await player.HPManager.take_damage(damage)
			var inventory_manager = player.InventoryManager
			inventory_manager.add_items(new_items)
