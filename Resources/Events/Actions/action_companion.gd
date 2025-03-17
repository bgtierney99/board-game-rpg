extends EventAction
class_name action_companion

@export var companion_data:lootData

func get_random_companion():
	var total_weight = 0
	var current_total_weight = 0
	var companion_pool = GameManager.get_table("weighted_companion_pool").table
	for stack in companion_pool:
		total_weight += stack["weight"]
	var rand_weight = randi_range(0, total_weight)
	for stack in companion_pool:
		current_total_weight += stack["weight"]
		if rand_weight <= current_total_weight:
			return stack["resource"]

func action(player:GameCharacter):
	await DialogueManager.run_dialogue("companion_found")
	var response = await DialogueManager.option_selected
	match response:
		"tame":
			var companion = companion_data
			if not companion:
				companion = get_random_companion()
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
