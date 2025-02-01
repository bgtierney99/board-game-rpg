extends Node

var trade_players = Array()
var trade_active = false

signal trade_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func check_trade():
	var space = GameManager.current_space
	for occupant in space.occupants:
		var item_count = occupant.InventoryManager.get_item_count()
		if item_count == 0:
			DialogueManager.text_vars["Subject"] = occupant.get_name()
			await DialogueManager.run_dialogue("empty_inventory")
			return
		if occupant != GameManager.current_player:
			init_trade(GameManager.current_player, occupant)
	DialogueManager.dialogue_finished.emit()
			
func init_trade(trader_1, trader_2):
	trade_active = true
	trade_players = [trader_1, trader_2]
	UIManager.change_state("TradeMenu")
	await trade_finished
	trade_active = false
