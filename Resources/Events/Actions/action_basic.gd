extends EventAction
class_name action_basic

func action(player:GameCharacter):
	await player.add_money(+5)
