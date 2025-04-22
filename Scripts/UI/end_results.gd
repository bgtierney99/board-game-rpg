extends MenuState

@onready var winner_message = $WinnerMessage
var current_max = 0
var player_results_scene = load("res://Scenes/UI/Menus/player_results.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	show_player_info()
	GameManager.scene_loaded.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func show_player_info():
	#for each playerf
	#line their models up at the top of the screen
	#under that, list their different point categories on the left with an increasing progress bar on the right
	#do this in a for loop and a tween. Loop over the list of point categories, then tween the total points they have, then iterate on the for loop when that tween finishes
	#the current highest points progress bar should always be at 100% with all the others lowering relative to [their points]/[winner points]% visibility.
	#the winner should probably be an array rather than a single character since it's entirely possible to tie in final points
	#list out and add up each player's points
	var player_totals = {}
	for player in GameManager.player_data:
		var player_results = player_results_scene.instantiate()
		$HBoxContainer.add_child(player_results)
		var point_num = player_results.get_node("Label")
		var point_bar = player_results.get_node("ProgressBar")
		player_results.add_child(player.model.instantiate())
		player_totals[player.name] = 0
		var total = 0
		for key in GameManager.player_points[player.name].keys():
			total += GameManager.point_rewards.reward_list[key]*GameManager.player_points[player.name][key]
			if total < 0:
				total = 0
			if total >= current_max:
				current_max = total
			for i in range(int(point_num.text), total):
				await get_tree().create_timer(0.05).timeout
				point_num.text = str(i)
				for child in $HBoxContainer.get_children():
					if child.has_node("ProgressBar") and child.has_node("Label"):
						child.get_node("ProgressBar").value = 100*(float(child.get_node("Label").text)/float(current_max))
		player_totals[player.name] = total
		point_num.text = str(total)
	#declare the winner based on who has the most total points
	var max_index = player_totals.values().find(player_totals.values().max())
	var winner = player_totals.keys()[max_index]
	winner_message.text = "The winner is %s!"%winner
