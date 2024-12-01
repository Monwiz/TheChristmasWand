extends npc

func _ready() -> void:
	if Stats.team & 0b100:
		if Stats._new_position != Vector2.ZERO:
			global_position.x = randi_range(2,15) + Stats._new_position.x
			global_position.y = randi_range(2,15) + Stats._new_position.y
		follow_team()
	WorldStats.action.connect(_on_dialogue_returned)

func _on_dialogue_returned(action: String):
	if action == "jethro.follow.team":
		follow_team()
	elif action == "jethro.walking":
		$AnimatedSprite2D.play()
	elif action == "jethro.staying_still":
		$AnimatedSprite2D.pause()
		
func follow_team():
	Stats.team |= 0b100
	follow($/root/Scene/Player)
