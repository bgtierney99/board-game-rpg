extends Node
class_name InventoryComponent

@export var inventory_size:int
var inventory:Array[lootData]

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory.resize(inventory_size)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_item(item):
	inventory.resize(inventory_size)
	var empty_index = inventory.find(null)
	if empty_index != -1:
		inventory[empty_index] = item

func add_items(items):
	for item in items:
		add_item(item)

func remove_item(item):
	inventory[inventory.find(item)] = null

func remove_items(items):
	for item in items:
		remove_item(item)

func clear():
	inventory.clear()
	inventory.resize(inventory_size)
	
func get_item_count():
	var item_count = 0
	for item in inventory:
		if item:
			item_count += 1
	return item_count

func filter_items(filter_type = null):
	var filtered_inventory = Array()
	for item in inventory:
		if item:
			if filter_type:
				if item.item_type == filter_type:
					filtered_inventory.append(item)
			else:
				filtered_inventory.append(item)
	return filtered_inventory

func sort_value(a, b):
	if a.getValue() < b.getValue():
		return true
	return false
