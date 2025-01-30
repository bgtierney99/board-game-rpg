extends ItemEffect
class_name DiskEffect

@export var min_roll: int = 1
@export var max_roll: int = 12

func effect(user):
	if user.in_battle:
		GameManager.send_num_range.emit(min_roll, max_roll)
		BattleManager.current_battle.set_attack(randi_range(min_roll, max_roll), 2)
	else:
		GameManager.send_num_result.emit(randi_range(min_roll, max_roll))
