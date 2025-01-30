extends Node3D
class_name itemContainer

@onready var loot_owner = ""
@export var InventoryManager: InventoryComponent
@export var inventory_size:int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open():
	$model/AnimationPlayer.play("Open")
	var item_list:Array[lootData] = InventoryManager.inventory
	while item_list.has(null):
		item_list.erase(null)
	return item_list

func give_items():
	var inv_popup = preload("res://Scenes/UI/Menus/inventory_popup.tscn").instantiate()
	add_child(inv_popup)
	inv_popup.show_inventory(InventoryManager.inventory)
	await GameManager.continue_game
	remove_child(inv_popup)
	queue_free()
