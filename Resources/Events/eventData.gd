extends Resource
class_name eventData

var player:GameCharacter
var space:BoardSpace

enum EVENT_TYPE {basic, prize, grave, checkpoint, boss, encounter, companion, trap_damage, trap_stuck, expedition, shop, fishing, dialogue}
@export var name: EVENT_TYPE
@export var event_texture:Texture
@export var event_color:Color
@export var event_action:EventAction

func event(player:GameCharacter):
	print("Doing event!")
	pass
