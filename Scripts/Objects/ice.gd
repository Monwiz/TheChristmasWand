extends RigidBody2D

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(linear_velocity)
	if collision:
		if collision.get_collider() is RigidBody2D:
			collision.get_collider().linear_velocity = linear_velocity
			linear_velocity = Vector2.ZERO
		elif collision.get_collider() is TileMapLayer:
			linear_velocity = Vector2.ZERO
