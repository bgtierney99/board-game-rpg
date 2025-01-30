extends Node3D
class_name GameCharacter

@export var HPManager:HealthComponent
@export var InventoryManager: InventoryComponent
@export var InputManager: InputComponent
@export var dialogue_key:String
var money = 0
var equipment := {"Holdable": null, "Wearable": null, "Companion": null, "Consumable": null}
var final_stats: Dictionary
var in_battle:bool = false
var is_dead:bool = false
var turn_count = 0
var character_model:Node3D
var speed_threshold_offset = 0
@onready var health_bar = $SubViewport/HealthBarBackground
@export var info:CharacterInfo:
	set(value):
		info = value
		if value:
			if info.model:
				character_model = info.model.instantiate()
				character_model.name = "model"
				var subject = $SubViewport
				if info.is_3D:
					subject = self
				subject.remove_child(character_model)
				subject.add_child(character_model)
			if HPManager:
				HPManager.health = info.base_stats["HP"]
				HPManager.max_health = info.base_stats["HP"]
				HPManager.no_health.connect(death)
				HPManager.low_health.connect(use_equipped_consumable)
			for key in info.base_stats.keys():
				final_stats[key] = info.base_stats[key]
			$SubViewport/HealthBarBackground/HealthBar.init_info(self)

signal eliminate_from_battle(player)
signal eliminated_from_battle
signal respawn(player)

func _input(event):
	pass
	
func ready():
	pass
	
func _process(delta):
	pass

func add_money(amount):
	money += amount
	if amount > 0:
		for i in range(amount):
			GameManager.add_points(self.name, "money_earned")
	elif amount < 0:
		for i in range(abs(amount)):
			GameManager.add_points(self.name, "money_lost")
	var money_label = Label3D.new()
	add_child(money_label)
	money_label.global_position = global_position+Vector3(0, 1.5, 0)
	money_label.text = "%+d"%amount
	await get_tree().create_timer(0.5).timeout
	remove_child(money_label)
	money_label.queue_free()

func use_equipped_consumable():
	var consumable = equipment["Consumable"]
	if consumable:
		print("Using equipped consumable!")
		consumable.effect.effect(self)
		equipment["Consumable"] = null

func use_equipment_effects():
	#run all the effects for the battler's current items
	for item_type in equipment.keys():
		if item_type != "Consumable":
			if equipment[item_type]:
				if equipment[item_type].effect:
					equipment[item_type].effect.effect(self)

func update_stats():
	var stats = {
	"additions": 
		{"HP":0, "Attack":0, "Defense":0, "Speed":0}, 
	"modifiers": 
		{"HP":0, "Attack":0, "Defense":0, "Speed":0}
	}
	#add up all the values
	for e_key in equipment.keys():
		var item = equipment[e_key]
		if item != null:
			for modifier in stats.keys():
				for key in stats[modifier].keys():
					stats[modifier][key] += item.stats[modifier][key]
	#add the values to the final stat count
	for key in final_stats.keys():
		var stat = info.base_stats[key]
		stat = (stat+stats["additions"][key])*(1+stats["modifiers"][key])
		#regardless of any debuffs or negative multipliers on stats, never let a stat go below 1
		final_stats[key] = clampi(stat, 1, 9999)
	HPManager.max_health = final_stats["HP"]
	var hp_diff = final_stats["HP"]-info.base_stats["HP"]
	HPManager.health = clampi(HPManager.health+hp_diff, 0, HPManager.max_health)
	

func get_speed_offset():
	#figure out the threshold for the current player to see if they get to move any extra spaces
	return floor(float(final_stats["Speed"])/10)-GameManager.movement_speed_threshold

func death():
	await GameManager.hp_bar_done
	is_dead = true
	eliminate_from_battle.emit(self)
	health_bar.visible = false
	#rotate the character to make them "fall over"
	var new_rotation = $Icon.rotation+Vector3(PI/2, 0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property($Icon, "rotation", new_rotation, 0.3).set_ease(Tween.EASE_IN)
	await tween.finished
	visible = false
	if in_battle:
		await eliminated_from_battle
	money -= int(money/3)
	if not is_in_group("Players"):
		queue_free()
	$Icon.rotation = Vector3.ZERO
