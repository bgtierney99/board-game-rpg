extends EventAction
class_name action_encounter

func setup_random_encounter():
	var encounter_table = GameManager.get_table("encounter_table")
	var enemy = load("res://Scenes/Characters/character.tscn").instantiate()
	var item_table = GameManager.get_table("item_table")
	enemy.InventoryManager.add_item(item_table.table.pick_random())
	enemy.info = encounter_table.table.pick_random()
	return enemy

func action(player:GameCharacter):
	var enemy:GameCharacter
	for child in space.get_children():
		if child is GameCharacter:
			enemy = child
			break
	if not enemy:
		enemy = setup_random_encounter()
	enemy.name = enemy.info.name
	enemy.money = enemy.info.money
	space.add_child(enemy)
	enemy.global_position = space.global_position+Vector3(0, 0, -1)
	reset_event.emit()
	GameManager.rotate_player_toward_target(player, enemy.position)
	var battler_list = [enemy]
	battler_list.append_array(space.occupants)
	BattleManager.enterBattle(battler_list)
