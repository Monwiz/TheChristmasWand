extends Teleport

func interact(player: CharacterBody2D):
	$AnimatedSprite2D.play("opened")
	await get_tree().create_timer(0.5).timeout
	teleport()
