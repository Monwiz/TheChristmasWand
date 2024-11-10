extends Resource
class_name Item

@export var name: String
var type: Types = Types.SIMPLE
@export var stackable: bool = false #it might be confusing for the player, so don't change this
@export var quantity: int = 1
@export_multiline var description: String

func _init() -> void:
	match type: #Python doesn't have interfaces for classes, so we have to get sure the functions exist. I don't think making empty functions will be good for that
		Types.CONSUMABLE:
			assert(has_method("use_on"),"Consumable items must have use_on(entity: Entity)->(message: String?) function")
		Types.CHECKABLE:
			assert(has_method("get_content"),"Checkable items must have get_content()->(content: Content) function")
		Types.TEACHABLE:
			assert(has_method("teach"),"Teachable items must have teach(entity: Entity)->(message: String?) function")
		Types.ENEMY_DIRECTED:
			assert(has_method("use_on"),"CanBeUsedOnEnemies items must have use_on(entity: Entity)->(message: String) function")

enum Types { SIMPLE, CONSUMABLE, ENEMY_DIRECTED, CHECKABLE, TEACHABLE }
#If your want add this in your project, there also can be used types such as WEARABLE/EQUIPMENT, ENTITY_DIRECTED, ALL_ENTITIES_DIRECTED
