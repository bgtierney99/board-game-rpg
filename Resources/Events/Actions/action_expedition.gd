extends EventAction
class_name action_expedition

func action(player:GameCharacter):
	match player.turn_count:
		0:
			#player.turn_count = turn_count
			await DialogueManager.run_dialogue("expedition_start")
			player.visible = false
		1:
			var damage = randi_range(0, player.HPManager.health-1)
			var reward_money = randi_range(1, 200)
			var item_table = GameManager.get_table("item_table").table
			await player.HPManager.take_damage(damage)
			await player.add_money(reward_money*5)
			for i in randi_range(1, 3):
				player.InventoryManager.add_item(item_table.pick_random())
			player.visible = true
			await DialogueManager.run_dialogue("expedition_end")
