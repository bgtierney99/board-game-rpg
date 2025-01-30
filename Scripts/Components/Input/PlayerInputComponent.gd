extends InputComponent
class_name PlayerInputComponent

@export var index = 0

func _input(event):
	if event.is_action_pressed("ui_accept"):
		print("Hitting a button!")
	if event.is_action_pressed("up_0"):
		print("Going up!")
	if event.is_action_pressed("select_%s"%index):
		print("Selecting")
		get_tree().quit()
