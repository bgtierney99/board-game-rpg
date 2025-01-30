class_name lootData
extends Resource

@export var name:String
@export var model:PackedScene
@export_enum("Holdable", "Wearable", "Companion", "Consumable") var item_type: String
@export var world:GameManager.WORLD
@export var effect: ItemEffect
@export var description: String
@export var price: int
@export var stats = {
	"additions": 
		{"HP":0, "Attack":0, "Defense":0, "Speed":0}, 
	"modifiers": 
		{"HP":0.0, "Attack":0.0, "Defense":0.0, "Speed":0.0}
}

func getValue():
	var stat_additions = 0
	var stat_multipliers = 1
	for key in stats["additions"].keys():
		stat_additions += stats["additions"][key]
	for key in stats["modifiers"].keys():
		stat_multipliers += stats["modifiers"][key]
		
	return stat_additions*stat_multipliers
	#return (stats["additions"]["HP"] + stats["additions"]["Attack"] + stats["additions"]["Defense"] + stats["additions"]["Speed"])*(1 + stats["modifiers"]["HP"] + stats["modifiers"]["Attack"] + stats["modifiers"]["Defense"] + stats["modifiers"]["Speed"])
