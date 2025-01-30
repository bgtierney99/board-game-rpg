extends InventoryPopup
class_name BattleRewardPopup

@onready var reward_text = $InventoryPanel/MarginContainer/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	grid_container = $InventoryPanel/MarginContainer/VBoxContainer/GridContainer
	inventory_panel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_reward_text(winner, prize_money):
	reward_text.text = "[center][b]%s won the battle![/b]\nPrize Money: [color=#28ff00]%s[/color]\n\nRewards:"%[winner, prize_money]
