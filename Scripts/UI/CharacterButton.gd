extends Button
class_name CharacterButton

signal set_character(info)
signal show_details(info)

@export var character_info: CharacterInfo
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_pressed():
	set_character.emit(self)

func set_selected_number(player_num):
	var indicator_scene = load("res://Scenes/UI/Menus/selection_indicator.tscn")
	if selected:
		var indicator = indicator_scene.instantiate()
		indicator.text = "P"+str(player_num+1)
		$GridContainer.add_child(indicator)
	else:
		var last_indicator = $GridContainer.get_children().back()
		$GridContainer.remove_child(last_indicator)
		last_indicator.queue_free()

func init_info():
	$SubViewport.add_child(character_info.model.instantiate())

func _on_focus_entered():
	show_details.emit(self)
