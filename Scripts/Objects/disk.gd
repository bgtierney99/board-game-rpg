extends Node3D

@export var min_num:int
@export var max_num:int
@onready var camera = $Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$Hologram.visible = false
	$NumberMesh.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spin(min=min_num, max=max_num):
	max_num = clampi(max, min, 999)
	min_num = clampi(min, 1, max)
	randomize()
	$model.global_rotation = Vector3.ZERO
	var new_rot = Vector3(0, 0, deg_to_rad(randi_range(1, 3)*360))
	var old_pos = $model.global_position
	var new_pos = old_pos+Vector3(0, randi_range(1, 3)*0.3, 0)
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property($model, "rotation", new_rot, 0.5)
	tween.tween_property($model, "global_position", new_pos, 0.25)
	tween.chain().tween_property($model, "global_position", old_pos, 0.25)
	await tween.finished
	$AnimationPlayer.play("spin")

func generate_result():
	var number_label = $NumberMesh
	number_label.visible = true
	var num_arr = []
	for i in range(min_num, max_num+1):
		num_arr.append(i)
	if min_num == max_num and num_arr.is_empty():
		num_arr.append(max_num)
	var result = num_arr.pick_random()
	#randomize a list of numbers and iterate through it
	num_arr.shuffle()
	for i in range(num_arr.size()):
		result = num_arr[i]
		number_label.mesh.text = str(result)
		var text_tween = get_tree().create_tween()
		text_tween.tween_property(number_label.mesh, "text", str(result), float(1/float(num_arr.size())))
		await text_tween.finished
	await get_tree().create_timer(0.5).timeout
	number_label.visible = false
	$Hologram.visible = false
	GameManager.send_num_result.emit(result)
