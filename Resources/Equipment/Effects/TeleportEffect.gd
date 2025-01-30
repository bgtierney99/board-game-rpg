extends ItemEffect
class_name TeleportEffect

@export var space_type:eventData

func effect(user):
	#TODO: Play some sort of whooshy animation to teleport the player
	GameManager.respawn_player.emit(user)
	GameManager.action_done.emit()
