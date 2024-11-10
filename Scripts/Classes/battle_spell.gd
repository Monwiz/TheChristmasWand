extends Resource
class_name BattleSpell

@export var name: String
var type: Types
@export_multiline var description: String

enum Types {BATTLE_DIRECTED, USER_DIRECTED, ALLIE_DIRECTED, ALL_ALLIES_DIRECTED, ENEMY_DIRECTED, ALL_ENEMIES_DIRECTED, ENTITY_DIRECTED, ALL_ENTITIES_DIRECTED}

#interface:
#func use_on(battle: Node2D)					for BATTLE_DIRECTED
#func use_on(entity: CharacterBody2D)			for USER_DIRECTED, ALLIE_DIRECTED, ENEMY_DIRECTED, ENTITY_DIRECTED
#func use_on(entities: Array[CharacterBody2D])	for ALL_ALLIES_DIRECTED, ALL_ENEMIES_DIRECTED, ALL_ENTITIES_DIRECTED
