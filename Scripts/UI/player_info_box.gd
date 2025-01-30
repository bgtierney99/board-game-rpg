extends Control



@export var player_name:RichTextLabel
@export var player_icon:TextureRect
@onready var health_bar = $HealthBar
@onready var turn_indicator = $TurnIndicator
@onready var battle_indicator = $BattleIndicator

var player:GameCharacter
var curr_hp_val:int = 0
var max_hp_val:int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func init_info(playerData:GameCharacter):
	player = playerData
	health_bar.init_info(playerData)
	player_name.text = "[center]"+playerData.info.name
	player_icon.texture = playerData.get_node("Icon").texture
	turn_indicator.visible = false
	battle_indicator.visible = false
