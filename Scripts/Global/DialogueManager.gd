extends Node

var dialogue_path = "res://Assets/Data/dialogue.json"
var dialogue_box: DialogueBox
var text_vars = {}

signal set_dialogue_options(action_list)
signal option_selected(action)
signal dialogue_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in UIManager.get_children():
		if child is DialogueBox:
			dialogue_box = child
	if not dialogue_box:
		push_error("Error: No MenuState with class_name DialogueBox in UI Manager")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_dialogue(id):
	#access the dialogue text from JSON by the ID and set the dialogue box text to that
	var file = FileAccess.open(dialogue_path, FileAccess.READ)
	if file:
		var content = JSON.parse_string(file.get_as_text())
		for entry in content["dialogue"]:
			if entry["id"] == id:
				#found the correct dialogue
				parse_entry(entry)
			
	else:
		push_error("Error: dialogue file not found.")

func parse_entry(entry):
	var responses = Array()
	for i in entry["response"].size():
		var action = entry["response"][i]["action"]
		var function = action["value"]
		var parameters = action["parameters"]
		var data = {
			"text": entry["response"][i]["value"],
			"action": function,
			"parameters": parameters
		}
		responses.append(data)
	text_vars["PlayerName"] = GameManager.current_player.get_name()
	var formatted_string = entry["text"].pick_random().format(text_vars)
	var speaker = entry["speaker"].format(text_vars)
	build_dialogue(speaker, formatted_string, responses)

func build_dialogue(speaker: String, text:String, button_elements):
	dialogue_box.show_box(speaker, text, button_elements)

func run_dialogue(id:String):
	if UIManager.state is DialogueBox:
		await dialogue_finished
	start_dialogue(id)
	await dialogue_finished

func end_dialogue():
	dialogue_finished.emit()
