extends EventAction
class_name action_companion

@export var companion_data:lootData

func action(player:GameCharacter):
	print("Companion event")
	await DialogueManager.run_dialogue("companion_found")
	var response = await DialogueManager.option_selected
	match response:
		"tame":
			reset_event.emit()
			var companion_table = GameManager.get_table("companion_table")
			var companion = companion_data
			if not companion:
				companion = companion_table.table.pick_random()
			DialogueManager.text_vars["Companion"] = companion.name
			var rand_chance = randf()
			#percentage chance that the creature damages the player
			if rand_chance <= 0.2:
				var damage = GameManager.calc_damage(companion.getValue(), player.final_stats["Defense"], randi_range(1, 12))
				await player.HPManager.take_damage(damage)
				await DialogueManager.run_dialogue("companion_attack")
			else:
				var inventory_manager = player.InventoryManager
				inventory_manager.add_item(companion)
				await DialogueManager.run_dialogue("got_companion")
				GameManager.add_points(player.name, "companions_befriended")
