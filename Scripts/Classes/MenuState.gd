extends Control
class_name MenuState

@export var animator: AnimationPlayer
signal reset_state

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func enter():
	visible = true
	
func exit():
	visible = false

func Input_Event(event):
	pass
