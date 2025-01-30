extends EventAction
class_name action_trap_stuck

func action(player:GameCharacter):
	match player.turn_count:
		0:
			await DialogueManager.run_dialogue("trap_stuck_start")
		1:
			await DialogueManager.run_dialogue("trap_stuck_end")

