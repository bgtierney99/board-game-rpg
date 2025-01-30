extends MenuState
class_name BattleMenu

signal set_damage(value, attack_points)

enum menu_state {options, attack, targets, rewards}
var active_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func enter():
	visible = true
	change_state(menu_state.options)

#options menu
func _on_fight_pressed():
	change_state(menu_state.attack)

func _on_heal_pressed():
	UIManager.change_state("BattleInventory")

#battle menu
func _on_full_pressed():
	BattleManager.current_battle.full_roll()

func _on_low_pressed():
	BattleManager.current_battle.low_roll()

func _on_high_pressed():
	BattleManager.current_battle.high_roll()

#targets
func setup_targets(target_list):
	var hbox = $Targets/HBoxContainer
	for button in hbox.get_children():
		hbox.remove_child(button)
		button.queue_free()
	for battler in target_list:
		var button = Button.new()
		hbox.add_child(button)
		button.custom_minimum_size = Vector2(400, 250)
		button.size = Vector2(400, 250)
		button.text = battler.info.name
		button.name = battler.info.name
		button.pressed.connect(set_target.bind(battler))
	change_state(menu_state.targets)

func set_target(target):
	BattleManager.target_picked.emit(target)

#inventory
func use_heal(amount):
	BattleManager.current_battle.set_heal(amount)

#rewards
func show_rewards(winner, prize_money, prize_pool):
	change_state(menu_state.rewards)
	active_menu.set_reward_text(winner, prize_money)
	await active_menu.show_inventory(prize_pool)

#general
func change_state(new_state):
	for child in get_children():
		child.visible = false
	active_menu = get_child(new_state)
	if active_menu:
		active_menu.visible = true
		if active_menu.has_node("HBoxContainer"):
			active_menu.get_node("HBoxContainer").get_child(0).grab_focus()
		else:
			active_menu.get_child(0).grab_focus()

func _on_back_pressed():
	change_state(menu_state.options)
