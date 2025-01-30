extends Control

signal state_changed(new_state)

var state: MenuState = null
var state_list = {}
@export var animator: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is MenuState:
			state_list[child.get_name()] = child
			child.reset_state.connect(_on_reset_state)
			child.animator = animator
			child.visible = false

func _input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func change_state(new_state):
	if state:
		state.exit()
	if new_state:
		state = state_list[new_state]
		state.enter()
		state_changed.emit(new_state)
	else:
		state = null

func _on_reset_state():
	change_state(null)
