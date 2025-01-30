extends Node
class_name HealthComponent

var max_health: int:
	set(value):
		max_health = value
		max_health_changed.emit(value)
var health: int:
	set(value):
		health = value
		current_health_changed.emit(value)

var health_percent = float(health)/float(max_health)

signal current_health_changed(value)
signal max_health_changed(value)
signal low_health
signal no_health

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func take_damage(damage):
	await setHealth(health-damage)

func heal(amount):
	print("Starting health: ", health)
	await setHealth(health+amount)
	print("Healed health: ", health)

func setHealth(value):
	health = clampi(value, 0, max_health)
	health_percent = float(health)/float(max_health)
	if health == 0:
		no_health.emit()
	if health_percent > 0 and health_percent <= 0.33:
		low_health.emit()
	current_health_changed.emit(health)
	await GameManager.hp_bar_done
