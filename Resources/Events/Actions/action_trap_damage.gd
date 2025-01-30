extends EventAction
class_name action_trap_damage

func action(player:GameCharacter):
	var damage = GameManager.calc_damage(30, player.final_stats["Defense"], randi_range(1, 12))
	await player.HPManager.take_damage(damage)
	if not player.is_dead:
		await DialogueManager.run_dialogue("trap_damage_reaction")

