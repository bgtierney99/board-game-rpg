extends Node
class_name InputComponent

@export var character:GameCharacter = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	character = get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
