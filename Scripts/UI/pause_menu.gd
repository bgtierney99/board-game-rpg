extends MenuState

func enter() -> void:
	visible = true
	$VBoxContainer/Resume.grab_focus()

func _on_resume_pressed() -> void:
	UIManager.change_state("PlayerActions")

func _on_options_pressed() -> void:
	print("Opening options menu!")

func _on_exit_pressed() -> void:
	GameManager.reset_to_main()

func Input_Event(event):
	if event.is_action_pressed("ui_cancel"):
		_on_resume_pressed()
