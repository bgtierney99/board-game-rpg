extends MenuState
class_name DialogueBox

@onready var speaker_label = $SpeakerBackground/SpeakerBox/MarginContainer/Label
@onready var text_label = $TextBackground/TextBox/MarginContainer/Label
@onready var button_container = $TextBackground/ButtonContainer
var text_tween:Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	DialogueManager.dialogue_finished.connect(reset)
	
func Input_Event(event):
	#pressing the confirm action skips the text
	if event.is_action_pressed("ui_accept"):
		await get_tree().create_timer(0.1).timeout
		text_tween.pause()
		text_tween.custom_step(999)
		text_tween.kill()

func reset():
	text_label.text = ""
	clear_buttons()

func show_box(speaker: String, text:String, button_elements):
	UIManager.change_state("DialogueBox")
	clear_buttons()
	speaker_label.text = speaker
	text_label.text = text
	#type dialogue one character at a time
	text_label.visible_ratio = 0
	text_tween = create_tween()
	var text_speed:float = 40.0 #characters per second
	var tween_time:float = text.length() / text_speed
	text_tween.tween_property(text_label, "visible_ratio", 1, tween_time)
	await text_tween.finished
	text_label.visible_ratio = 1
	add_buttons_to_box(button_elements)
	
func add_buttons_to_box(button_elements):
	#enemy should show the box for a short time then immediately close it
	var input_manager = GameManager.current_player.InputManager
	if input_manager is EnemyInputComponent:
		await get_tree().create_timer(0.4).timeout
		var result_button = input_manager.dialogue_button_selection(button_elements)
		await select_option(result_button["action"], result_button["parameters"])
		return
	#remove old buttons
	clear_buttons()
	var dialogueButton = preload("res://Scenes/UI/Menus/dialogue_box_button.tscn")
	#create new ones
	var buttons = Array()
	for i in button_elements.size():
		var button = dialogueButton.instantiate()
		button_container.add_child(button)
		buttons.append(button)
		buttons[i].visible = true
		buttons[i].text = button_elements[i]["text"]
		var action = button_elements[i]["action"]
		var parameters = button_elements[i]["parameters"]
		buttons[i].pressed.connect(select_option.bind(action, parameters))
	if not UIManager.state is DialogueBox or buttons.is_empty():
		return
	buttons[0].grab_focus()

func clear_buttons():
	for button in button_container.get_children():
		button.queue_free()

func select_option(action:String, parameters:Array=[]):
	clear_buttons()
	reset_state.emit()
	#general action cases
	match action:
		"next":
			await DialogueManager.run_dialogue(parameters[0])
	DialogueManager.dialogue_finished.emit()
	DialogueManager.option_selected.emit(action)
