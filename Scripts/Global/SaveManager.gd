extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func save():
	get_tree().current_scene.get_node("SavingLabel").visible = true
	await get_tree().create_timer(1).timeout
	get_tree().current_scene.get_node("SavingLabel").visible = false
