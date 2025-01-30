extends EventAction
class_name action_fishing

@export var min_fish_time:float = 2.0
@export var max_fish_time:float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func action(player:GameCharacter):
	#TODO:Throw the line into the water
	
	#Have the fishing rod wait the pre-requisite time
	await space.get_tree().create_timer(randf_range(min_fish_time, max_fish_time)).timeout
	var button = Button.new()
	button.text = "Reel!"
	button.pressed.connect(get_fish)
	space.add_child(button)
	button.grab_focus()
	await space.get_tree().create_timer(1).timeout
	button.queue_free()
	
func get_fish():
	print("Got the fish!")
