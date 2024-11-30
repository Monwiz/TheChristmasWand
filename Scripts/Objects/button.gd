extends Area2D

signal pressed()
signal released()

func _on_body_entered(body: Node2D) -> void:
	if body.name in ["Snow", "Ice"]:
		$AnimatedSprite2D.play("pressed")
		pressed.emit()

func _on_body_exited(body: Node2D) -> void:
	if body.name in ["Snow", "Ice"]:
		if has_overlapping_bodies() and get_overlapping_bodies().any(
			func(body1):
				return body1.name in ["Snow", "Ice"]
		): return
		$AnimatedSprite2D.play("default")
		released.emit()
