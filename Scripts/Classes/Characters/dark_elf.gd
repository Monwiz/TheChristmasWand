extends npc

func _ready() -> void:
	WorldStats.action.connect(_on_dialogue_returned)
	$HealthBar.max_value = hp
	$HealthBar.value = hp

func _on_dialogue_returned(action: String):
	if action == "dark_elf.fake":
		$AnimatedSprite2D.play("faking")
	elif action == "dark_elf.unfake":
		$AnimatedSprite2D.play("walking")
		$AnimatedSprite2D.pause()
