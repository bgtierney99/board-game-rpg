extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_info():
	var info_box_scene = preload("res://Scenes/UI/Menus/player_info_box.tscn")
	for i in GameManager.player_list.size():
		var info_box = info_box_scene.instantiate()
		$HBox.add_child(info_box)
		$HBox.move_child(info_box, i)
		info_box.init_info(GameManager.player_list[i])
	if GameManager.num_characters <= 6:
		$HBox.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		$HBox.alignment = BoxContainer.ALIGNMENT_BEGIN

func setup_boss_health(boss:GameCharacter):
	$BossHealth.init_info(boss)

func updateBoxStatus(player:GameCharacter):
	var default_color = Color(22, 50, 72)
	var turn_color = Color(0, 69, 97)
	var battle_color = Color(128, 0, 0)
	for box in $HBox.get_children():
		box.color = default_color
		#don't run anything after this if it's not the current player being updated
		if box.player != player:
			continue
		box.color = turn_color
		if not BattleManager.current_battle or box.player != BattleManager.current_battle.current_player:
			continue
		box.color = battle_color

func updateStatus():
	var hbox = $HBox
	var current_turn_box = hbox.get_child(0)
	var current_battler_box = hbox.get_child(0)
	for box in hbox.get_children():
		box.turn_indicator.visible = false
		box.battle_indicator.visible = false
		if box.player == GameManager.current_player:
			current_turn_box = box
		if BattleManager.current_battle and box.player == BattleManager.current_battle.current_battler:
				current_battler_box = box
	current_turn_box.turn_indicator.visible = true
	var child_index = hbox.get_children().find(current_turn_box)
	if BattleManager.current_battle:
		current_battler_box.battle_indicator.visible = true
	if child_index > 5:
		hbox.position.x = (child_index-5)*(-current_turn_box.size.x)
	else:
		hbox.position.x = 0
