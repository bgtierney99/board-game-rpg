extends EventAction
class_name action_checkpoint

func action(player:GameCharacter):
	player.HPManager.health = player.HPManager.max_health
	GameManager.set_spawnpoint.emit(player, space)
	SaveManager.save()
