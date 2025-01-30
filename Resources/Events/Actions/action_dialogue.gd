extends EventAction
class_name action_dialogue

@export var dialogue_key:String

func action(player:GameCharacter):
	print("Running dialogue")
	var character:GameCharacter
	for child in space.get_children():
		if child is GameCharacter:
			print("Found child: ", child)
			character = child
			break
	DialogueManager.text_vars["Speaker"] = character.info.name
	await DialogueManager.run_dialogue(character.dialogue_key)
