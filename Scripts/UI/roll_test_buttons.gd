extends MenuState

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_random_pressed():
	process_num(randi_range(1, 6))


func _on_1_pressed():
	process_num(1)


func _on_2_pressed():
	process_num(2)


func _on_3_pressed():
	process_num(3)


func _on_4_pressed():
	process_num(4)


func _on_5_pressed():
	process_num(5)


func _on_6_pressed():
	process_num(6)

func process_num(num):
	GameManager.send_num_result.emit(num)
