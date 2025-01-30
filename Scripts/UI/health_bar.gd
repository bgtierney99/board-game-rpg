extends Control

#@onready var hp_bar = $hp_bar
#@onready var hp_val = $hp_val
@export var hp_bar: ProgressBar
@export var hp_val: Label
var curr_hp_val:int = 0
var max_hp_val:int = 0
var player:GameCharacter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_info(playerData:GameCharacter):
	player = playerData
	playerData.HPManager.current_health_changed.connect(current_hp_changed)
	playerData.HPManager.max_health_changed.connect(max_hp_changed)
	curr_hp_val = playerData.HPManager.health
	max_hp_val = playerData.final_stats["HP"]
	hp_bar.value = 100
	hp_val.text = str(curr_hp_val)+"/"+str(max_hp_val)

func current_hp_changed(value):
	await update_hp(value, player.HPManager.max_health)
	
func max_hp_changed(value):
	#await update_hp(player.HPManager.health, value)
	max_hp_val = value

func update_hp(new_min, new_max):
	var old_min = curr_hp_val
	var tween = get_tree().create_tween().set_parallel(true)
	var hp_speed = 30 #hp per second
	var tween_time = float(abs(old_min-new_min)/float(hp_speed))
	tween.tween_method(set_hp_values, old_min, new_min, tween_time)
	if UIManager.state:
		UIManager.state.visible = false
	await tween.finished
	curr_hp_val = new_min
	if new_max:
		max_hp_val = clampi(new_max, curr_hp_val, 9999)
	GameManager.hp_bar_done.emit()
	if UIManager.state:
		UIManager.state.visible = true

func set_hp_values(value):
	hp_bar.value = 100*(float(value)/float(max_hp_val))
	hp_val.text = str(value)+"/"+str(max_hp_val)
