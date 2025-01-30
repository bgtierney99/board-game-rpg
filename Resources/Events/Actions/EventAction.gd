extends Resource
class_name EventAction

#var player:GameCharacter
var space:BoardSpace
@export var turn_count:int = 0

signal reset_event

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func action(player:GameCharacter):
	print("Doing action!")
