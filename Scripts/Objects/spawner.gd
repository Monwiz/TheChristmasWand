extends Area2D

var ice = preload("res://Objects/ice.tscn")
var snow = preload("res://Objects/snow.tscn")
var object: RigidBody2D

func spawn_ice():
	if object: return
	object = ice.instantiate()
	object.tree_exited.connect(despawn)
	add_child(object)
	object.get_node("CollisionShape2D").scale = Vector2(4,4) #for some reason it becomes 0.25x after adding to a scene
	object.get_node("Sprite2D").scale = Vector2(4,4)
	$AnimatedSprite2D.play("disabled")

func spawn_snow():
	if object: return
	object = snow.instantiate()
	object.tree_exited.connect(despawn)
	add_child(object)
	object.get_node("CollisionShape2D").scale = Vector2(4,4)
	object.get_node("Sprite2D").scale = Vector2(4,4)
	$AnimatedSprite2D.play("disabled")
	
func despawn():
	object = null
	$AnimatedSprite2D.play("default")
