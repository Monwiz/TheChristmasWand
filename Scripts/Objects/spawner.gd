extends Area2D
class_name Spawner

var ice = preload("res://Objects/ice.tscn")
var snow = preload("res://Objects/snow.tscn")
var object: RigidBody2D

func spawn_ice():
	if object: return
	object = ice.instantiate()
	object.tree_exited.connect(despawn)
	$AnimatedSprite2D.play("disabled")
	add_child(object)
	await get_tree().physics_frame #saves from collision because of wrong scaling
	await get_tree().physics_frame
	object.get_node("CollisionShape2D").scale = Vector2(4,4) #for some reason it becomes 0.25x after adding to a scene
	object.get_node("Sprite2D").scale = Vector2(4,4)

func spawn_snow():
	if object: return
	object = snow.instantiate()
	object.tree_exited.connect(despawn)
	$AnimatedSprite2D.play("disabled")
	add_child(object)
	await get_tree().physics_frame #just saves from showing as big
	await get_tree().physics_frame
	object.get_node("CollisionShape2D").scale = Vector2(4,4)
	object.get_node("Sprite2D").scale = Vector2(4,4)
	
func despawn():
	object = null
	$AnimatedSprite2D.play("default")
