extends EventAction
class_name action_boss

func action(player:GameCharacter):
	await DialogueManager.run_dialogue("boss_battle_begin")
	#initiate a battle between the trigger player and the boss
	var boss = space.get_tree().get_nodes_in_group("Boss")[0]
	var battler_list = [boss]
	battler_list.append_array(space.occupants)
	BattleManager.enterBattle(battler_list)
