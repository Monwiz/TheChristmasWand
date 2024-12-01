extends npc

func _ready() -> void:
	if Stats.team & 0b100:
		if Stats._new_position != Vector2.ZERO:
			global_position = Stats._new_position
		follow_team()
	WorldStats.action.connect(_on_dialogue_returned)

func _on_dialogue_returned(action: String):
	if action == "snow_queen.follow.team":
		follow_team()
		
func follow_team():
	Stats.team |= 0b010
	if Stats.team & 0b100 and $/root/Scene/Jethro:
		follow($/root/Scene/Jethro)
	else:
		follow($/root/Scene/Player)
