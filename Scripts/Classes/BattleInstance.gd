extends Resource
class_name BattleInstance

signal action_selected
signal current_battle(instance)

var current_battler:GameCharacter
var battler_list:Array
var extra_turns: Array
var full_set: Array
var loser_list:Array
var battle_points: Dictionary
var battle_over = false
var current_state
var prize_pool:Array = Array()
var prize_money = 0

enum BATTLE_STATE {
	START_SET,
	START_TURN,
	ACTION,
	END_TURN,
	END_SET,
	END_BATTLE
}

# Called when the node enters the scene tree for the first time.
func _ready():
	UIManager.change_state("BattleMenu`")

func sort_speed(a, b):
	if a.final_stats["Speed"] > b.final_stats["Speed"]:
		return true
	return false

func change_battle_state(new_state:BATTLE_STATE):
	match new_state:
		BATTLE_STATE.START_SET:
			full_set = GameManager.unique_copy(extra_turns)
			full_set.append_array(battler_list)
			extra_turns.clear()
			change_battle_state(BATTLE_STATE.ACTION)
		BATTLE_STATE.ACTION:
			BattleManager.update_turn_display(full_set)
			if not full_set[0].is_dead:
				current_battler = full_set[0]
				if current_battler.InputManager is EnemyInputComponent:
					current_battler.InputManager.battle_action()
				else:
					UIManager.change_state("BattleMenu")
				await action_selected
			change_battle_state(BATTLE_STATE.END_TURN)
		BATTLE_STATE.END_TURN:
			full_set.remove_at(0)
			for battler in battler_list:
				if battler.is_dead:
					eliminate_battler(battler)
				else:
					battler.use_equipment_effects()
			#move forward if there are still battlers in the set
			if battler_list.size() == 1 or GameManager.boss_hp == 0:
				battle_over = true
			if full_set.is_empty() or battle_over:
				change_battle_state(BATTLE_STATE.END_SET)
			elif not full_set.is_empty():
				change_battle_state(BATTLE_STATE.ACTION)
		BATTLE_STATE.END_SET:
			BattleManager.setCurrentBattle(null)
			if not battle_over:
				BattleManager.set_finished.emit()
				return
			change_battle_state(BATTLE_STATE.END_BATTLE)
		BATTLE_STATE.END_BATTLE:
			var winner = current_battler
			for battler in battler_list:
				battler.in_battle = false
			if winner.is_in_group("Players"):
				GameManager.add_points(winner.name, "battles_won")
				#end-game condition
				if GameManager.boss_hp == 0:
					GameManager.add_points(winner.name, "boss_defeated")
					GameManager.win_game()
					return
				await UIManager.state_list["BattleMenu"].show_rewards(winner.name, prize_money, prize_pool)
				battler_list[0].InventoryManager.add_items(prize_pool)
			BattleManager.set_finished.emit()
	
func start_set():
	change_battle_state(BATTLE_STATE.START_SET)

func battle_setup(battlers:Array):
	battler_list = GameManager.unique_copy(battlers)
	#sort battlers by speed stat
	battler_list.sort_custom(sort_speed)
	for battler in battler_list:
		battler.money = battler.money
		battler.in_battle = true
		if not battle_points.keys().has(battler):
			battle_points[battler] = 2
	BattleManager.setCurrentBattle(self)
	start_set()

func manage_battle_points(attack_points:int):
	battle_points[current_battler] -= attack_points
	#resetting points if they go negative
	if battle_points[current_battler]:
		if battle_points[current_battler] < 0:
			extra_turns.erase(current_battler)
			battle_points[current_battler] = 2
		elif battle_points[current_battler] == 0:
			battle_points[current_battler] = 2
		#insert new turn in the next set if there are still points remaining
		else:
			extra_turns.append(current_battler)
			extra_turns.sort_custom(sort_speed)

func eliminate_battler(battler:GameCharacter):
	extra_turns.erase(battler)
	battler_list.erase(battler)
	full_set = GameManager.unique_copy(extra_turns)
	full_set.append_array(battler_list)
	loser_list.append(battler)
	battler.in_battle = false
	GameManager.current_space.remove_player(battler)
	var battler_items = battler.InventoryManager.filter_items()
	if battler_items.size() > 0:
		var item_key = randi_range(0, battler_items.size()-1)
		var prize = battler_items[item_key]
		battler.InventoryManager.remove_item(battler_items[item_key])
		prize_pool.append(prize)
	if battler.is_in_group("Boss"):
		battle_over = true
	prize_money += int(battler.money/3)
	battler.eliminated_from_battle.emit()

func determine_target():
	#create a list of battlers that doesn't include the current one
	var opponent_list = GameManager.unique_copy(battler_list)
	opponent_list.erase(current_battler)
	#set a target
	var target = opponent_list[0]
	if opponent_list.size() > 1:
		UIManager.state_list["BattleMenu"].setup_targets(opponent_list)
		if current_battler.InputManager is EnemyInputComponent:
			return current_battler.InputManager.pick_target(opponent_list)
		else:
			return await BattleManager.target_picked
	return target

func high_roll():
	set_attack(randi_range(10, 12), 4)

func low_roll():
	set_attack(randi_range(1, 4), 1)

func full_roll():
	set_attack(randi_range(1, 12), 2)

func set_damage_roll(damage_roll):
	var attack_points = 2
	if damage_roll >= 1 and damage_roll <= 6:
		attack_points = 1
	elif damage_roll >= 4 and damage_roll <= 6:
		attack_points = 1
	set_attack(damage_roll, attack_points)

func set_attack(damage_roll:int, attack_points:int):
	#determine the target for the attack
	var target = await determine_target()
	do_targeted_attack(target, damage_roll, attack_points)
	
func do_targeted_attack(target:GameCharacter, damage_roll:int, attack_points:int):
	manage_battle_points(attack_points)
	#damage calculation for HP loss
	var attack_power = current_battler.final_stats["Attack"]
	var defense_power = target.final_stats["Defense"]
	if target:
		var damage:int = clampi(GameManager.calc_damage(attack_power, defense_power, damage_roll), 0, target.HPManager.health)
		var damage_roll_label = Label3D.new()
		current_battler.add_child(damage_roll_label)
		damage_roll_label.global_position = current_battler.global_position+Vector3(0, 1.5, 0)
		damage_roll_label.text = "Got a %s!\nMultiplier: %s"%[damage_roll, snappedf(float((damage_roll-1)/5.5), 0.01)]
		await BattleManager.animate_attack(current_battler, target, damage)
		current_battler.remove_child(damage_roll_label)
		damage_roll_label.queue_free()
		await target.HPManager.take_damage(damage)
		#boss-specific things
		if target.is_in_group("Boss"):
			for i in range(damage):
				GameManager.add_points(current_battler.name, "damage_to_boss")
			GameManager.boss_hp = target.HPManager.health
			#if GameManager.boss_hp == 0:
				#battle_over = true
	action_selected.emit()
	
func animate_attacker():
	pass

func animate_defender():
	pass

func set_heal(amount):
	action_selected.emit()
