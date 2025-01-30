extends Node3D
class_name itemShop

@export var shop_inventory:Array[lootData]
@export var InventoryManager: InventoryComponent
@onready var shopkeeper = $Shopkeeper
var active_inventory:Array[lootData]

# Called when the node enters the scene tree for the first time.
func _ready():
	shop_inventory.resize(InventoryManager.inventory.size())
	InventoryManager.inventory = shop_inventory

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass 

func open(shop_state:int):
	UIManager.state_list["ShopInventory"].set_data(GameManager.current_player, self, shop_state)
	UIManager.change_state("ShopInventory")
	await GameManager.continue_game
