@tool
extends Node

@export var space_distance_threshold:float = 2
@export var space_height_threshold:float = 0.75
@export var board: Node3D
@export var spaces: Node
@export var generate_and_link: bool = false:
	set = gen_and_link
@export var generate: bool = false:
	set = gen_spaces
@export var link: bool = false:
	set = link_spaces
@export var clear: bool = false:
	set = clear_spaces
var initial_spaces = Array()
@onready var gen_enabled: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func gen_spaces(button_val):
	generate = false
	if spaces.get_child_count() <= 1:
		print("No spaces to connect to!")
		return
	if gen_enabled:
		print("Generating spaces!")
		var space_list: Array = GameManager.unique_copy(spaces.get_children()) #Parent should always be the Board, and the Spaces node should always hold the initial spaces
		initial_spaces = GameManager.unique_copy(space_list)
		var space_scene = preload("res://Scenes/Objects/space.tscn")
		var space_positions = Array()
		var space_dict := {}
		#add initial spaces into list
		for space in space_list:
			space_positions.append(space.position)
			space_dict[space.position] = null
			var space_pos = space.position
			for other_space in space_list:
				#get position for new in-between spaces
				var other_space_pos = other_space.position
				if other_space_pos != space_pos:
					var diff = other_space_pos-space_pos
					if diff.x == 0 or diff.z == 0:
						var num_spaces = space_pos.distance_to(other_space_pos)/space_distance_threshold-1
						for i in range(num_spaces):
							var new_space_pos = space_pos+((space_distance_threshold*diff.normalized())*(i+1))
							space_dict[new_space_pos] = null
		#generate spaces
		for space_pos in space_dict.keys():
			if not space_positions.has(space_pos):
				var new_space = space_scene.instantiate()
				spaces.add_child(new_space)
				new_space.position = space_pos
				space_list.append(new_space)
		set_space_data(space_list)
		gen_enabled = false
	else:
		print("Cannot generate. Clear generated spaces first!")

func link_spaces(button_val):
	link = false
	if spaces.get_child_count() <= 1:
		print("No spaces to link together!")
		return
	#link spaces together
	print("Linking spaces!")
	var space_list: Array = GameManager.unique_copy(spaces.get_children())
	for space in space_list:
		for other_space in space_list:
			if other_space != space:
				var dist_to_space = space.position.distance_to(other_space.position)
				#adjacent spaces can't be more than the threshold away or too high
				if dist_to_space == space_distance_threshold and other_space.position.y <= space.position.y+space_height_threshold:
					if other_space.position.x > space.position.x: space.adjacent_spaces["Right"] = other_space
					elif other_space.position.x < space.position.x: space.adjacent_spaces["Left"] = other_space
					elif other_space.position.z > space.position.z: space.adjacent_spaces["Back"] = other_space
					elif other_space.position.z < space.position.z: space.adjacent_spaces["Forward"] = other_space
	
func set_space_data(space_list: Array):
	for space in space_list:
		if space.event_data.name == space.event_data.EVENT_TYPE.basic:
			var event_table:dataTable = GameManager.get_table("event_table")
			var new_event = event_table.table.pick_random()
			space.event_data = new_event
			#populate prize spaces
			if new_event.name == space.event_data.EVENT_TYPE.prize:
				space.set_prize_space()

func gen_and_link(button_val):
	print("Generating and linking spaces!")
	generate = true
	link = true
	generate_and_link = false

func clear_spaces(button_val):
	if not gen_enabled:
		print("Clearing spaces!")
		var space_list: Array = GameManager.unique_copy(spaces.get_children())
		for space in space_list:
			if not initial_spaces.has(space):
				print("Not in %s: %s"%[initial_spaces, space])
				spaces.remove_child(space)
				space.queue_free()
		gen_enabled = true
	else:
		print("Spaces already cleared.")
	clear = false
