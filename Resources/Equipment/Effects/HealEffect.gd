extends ItemEffect
class_name HealEffect

@export_range(0, 1, 0.01) var hp_percent: float = 0.0

func effect(user):
	var hp_manager = user.get_node("HealthComponent")
	await hp_manager.heal(int(hp_manager.max_health*hp_percent))
