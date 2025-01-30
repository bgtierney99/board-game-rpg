extends Resource
class_name CharacterInfo

@export var model:PackedScene
@export var name:String
@export var base_stats = {"HP":0, "Attack":0, "Defense":0, "Speed":0}
enum STRAT_TYPES { RANDOM, SCAVENGER, AGGRESSIVE }
@export var world:GameManager.WORLD
@export var smart_battler:bool = true
@export var is_3D:bool = false
@export var strategy:STRAT_TYPES
@export var money:int
