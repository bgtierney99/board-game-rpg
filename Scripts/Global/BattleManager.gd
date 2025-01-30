extends Node

signal set_finished
signal target_picked(target)

var battle_list = Array()
var current_battle: BattleInstance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func enterBattle(battlers: Array):
	#destroy any battle instances that have ended
	for battle in battle_list:
		if battle.battle_over:
			killBattle(battle)
	#find one if it still exists
	var existing_battle:BattleInstance = findExistingBattle(battlers)
	if existing_battle:
		existing_battle.current_battle.emit()
		for battler in battlers:
			if not existing_battle.battler_list.has(battler):
				existing_battle.battler_list.append(battler)
		await existing_battle.battle_setup(existing_battle.battler_list)
	else:
		await initBattle(battlers)

func initBattle(battlers: Array):
	var new_battle = BattleInstance.new()
	battle_list.append(new_battle)
	await new_battle.battle_setup(battlers)
	
func killBattle(instance: BattleInstance):
	battle_list.erase(instance)
	set_finished.emit()
	
func setCurrentBattle(instance):
	current_battle = instance
	var turn_display = get_tree().current_scene.get_node("TurnOrder")
	if current_battle:
		turn_display.visible = true
	else:
		turn_display.visible = false
	
func findExistingBattle(battler_list):
	var result:BattleInstance = null
	for battler in battler_list:
		#check if these players are in another battle
		for battle in battle_list:
				if battle.battler_list.has(battler):
					result = battle
					if not battle.battler_list.has(GameManager.current_player):
						battle.battler_list.append(GameManager.current_player)
	return result

func check_battle():
	var space = GameManager.current_space
	if space.occupants.size() > 1:
		enterBattle(space.occupants)
	
func animate_attack(attacker, defender, damage):
	#TODO: attack animation based on whatever equipment the player has that modifies their attack. Otherwise, just a punch.
	#TODO: defend animation from the target, based on whatever defensive equipment they have. Otherwise, do an arm block.
	#TODO: dodge animation for when the damage is 0 so it misses the target
	#await the attack animation or the defend animation, whichever finishes last
	var tween = get_tree().create_tween()
	var attacker_pos = attacker.global_position
	var defender_pos = defender.global_position
	attacker.character_model.look_at(defender_pos)
	defender.character_model.look_at(attacker_pos)
	
	tween.tween_property(attacker, "global_position", defender_pos, 0.5).set_ease(Tween.EASE_OUT)
	if damage == 0:
		#dodge animation
		tween.tween_property(defender, "global_position", defender_pos-(defender_pos.direction_to(attacker_pos)*0.5), 0.1).set_ease(Tween.EASE_OUT)
	else:
		#defend animation
		tween.tween_property(defender, "global_position", defender_pos-(defender_pos.direction_to(attacker_pos)*0.2), 0.1).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(attacker, "global_position", attacker_pos, 0.5).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(defender, "global_position", defender_pos, 0.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
#turn_order
func update_turn_display(order):
	var turn_order_display = get_tree().current_scene.get_node("TurnOrder")
	var turn_box_scene = preload("res://Scenes/UI/Menus/turn_order_box.tscn")
	turn_order_display.visible = true
	#delete the old children
	for child in turn_order_display.get_children():
		child.queue_free()
	#add all the updated ones
	for battler in order:
		var turn_box = turn_box_scene.instantiate()
		turn_box.set_data(battler)
		turn_order_display.add_child(turn_box)
		#turn_box.position.x = turn_box.size.x
		#var tween = get_tree().create_tween()
		#tween.tween_property(turn_box, "position", 0, 0.25)
		#await tween.finished
		#tween turn_box toward 0
