extends Node2D
class_name Teleport

@export_file("*.tscn") var new_scene_location: String
@export var new_music: AudioStream
@export var new_position: Vector2
@onready var anim: AnimationPlayer = $/root/Scene/Fading

func teleport():
	anim.play("fade-out")
	await anim.animation_finished
	if new_music:
		BGM.play_calm(new_music)
	Stats._new_position = new_position
	get_tree().change_scene_to_file(new_scene_location)
