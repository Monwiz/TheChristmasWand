extends BattleSpell

func _init() -> void:
	type = Types.ALL_ENTITIES_DIRECTED
	
func use_on(entities: Array[CharacterBody2D]):
	for entity in entities:
		entity.hurt(9999999)
