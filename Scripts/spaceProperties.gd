extends Node3D
class_name BoardSpace

@onready var points = $Points

@export var adjacent_spaces: Dictionary = {"Forward": null, "Back": null, "Left": null, "Right": null}
@export var ActionManager:EventAction
@export var event_data: eventData:
	set(value):
		event_data = value.duplicate()
		set_event_data()
var occupants = Array()
var trigger_player:GameCharacter

signal space_picked(space)
signal set_spawnpoint(player, space)
signal occupants_changed

# Called when the node enters the scene tree for the first time.
func _ready():
	$DirectionControl.visible = false
	get_node("model").get_node("Circle").get_mesh().resource_local_to_scene = true
	set_event_data()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func set_event_data():
	if get_child_count() > 0 and event_data:
		if event_data.event_action and not ActionManager:
			ActionManager = event_data.event_action.duplicate()
			ActionManager.space = self
			ActionManager.reset_event.connect(reset_event)
		#event_data.space = self
		#event_data.Actionreset_event.connect(reset_event)
		get_node("event_image").texture = event_data.event_texture
		var material = StandardMaterial3D.new()
		material.albedo_color = event_data.event_color
		var mesh = get_node("model").get_node("Circle").get_mesh()
		mesh.surface_set_material(0, material)

func add_player(player:GameCharacter):
	occupants.push_front(player)
	occupants_changed.emit()
	trigger_player = player
	
func remove_player(player:GameCharacter):
	occupants.erase(player)
	occupants_changed.emit()

func place_object(object):
	#place the object in a spot that doesn't block a space
	var possible_spots = {
		"Forward": Vector3(0, 0, -1),
		"Back": Vector3(0, 0, 1),
		"Left": Vector3(-1, 0, 0),
		"Right": Vector3(1, 0, 0)
	}
	#Prioritizing forward-facing objects will look better for the camera
	var result:String
	if not adjacent_spaces["Forward"]:
		result = "Forward"
	elif not adjacent_spaces["Left"] or not adjacent_spaces["Right"]:
		if global_position.x < 0:
			result = "Left"
		else:
			result = "Right"
	else:
		result = "Back"
	object.global_position = self.global_position+possible_spots[result]
	var dir = object.global_position.direction_to(global_position)
	object.rotation.y = atan2(dir.x, dir.z)

func interaction_check():
	GameManager.space_check_subject = null
	for occupant in occupants:
		if not occupant.in_battle and occupant.visible and occupant != GameManager.current_player:
			GameManager.space_check_subject = occupant
			break
	if GameManager.space_check_subject:
		DialogueManager.text_vars["Subject"] = GameManager.space_check_subject.name
		await DialogueManager.run_dialogue("space_interaction")
		var response = await DialogueManager.option_selected
		match response:
			"battle":
				BattleManager.check_battle()
			"trade":
				TradeManager.check_trade()

func reset_event():
	event_data = load("res://Resources/Events/event_basic.tres")

func show_direction_buttons(space_choices):
	var direction_control = $DirectionControl
	direction_control.visible = true
	var dir_choices = Array()
	for dir in space_choices.keys():
		if space_choices[dir] != null:
			dir_choices.append(dir)
	for button in direction_control.get_children():
		button.flat = true
		button.pressed.connect(set_direction.bind(button.get_name()))
		button.visible = false
	for direction in dir_choices:
		direction_control.get_node(direction).visible = true
	direction_control.get_node(dir_choices[0]).grab_focus()
	
func set_direction(dir:String):
	$DirectionControl.visible = false
	space_picked.emit(adjacent_spaces[dir])

func event():
	#await event_data.event(trigger_player)
	if ActionManager:
		await ActionManager.action(trigger_player)
		#general post-event stuff
		if trigger_player.turn_count > 0:
			trigger_player.turn_count -= 1
		else:
			trigger_player.turn_count = ActionManager.turn_count
