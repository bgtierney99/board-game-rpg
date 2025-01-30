extends EventAction
class_name action_grave

func setup_container(inventory):
	var container = load("res://Scenes/Objects/container.tscn").instantiate()
	container.InventoryManager.inventory.resize(inventory.size())
	container.InventoryManager.add_items(inventory)
	container.name = "container"
	space.add_child(container)
	space.place_object(container)

func action(player:GameCharacter):
	var container:itemContainer = space.get_node("container")
	GameManager.rotate_player_toward_target(player, container.global_position)
	var new_items = container.open()
	await GameManager.continue_game
	var inventory_manager = player.InventoryManager
	inventory_manager.add_items(new_items)
	GameManager.add_points(player.name, "graves_robbed")
	reset_event.emit()
