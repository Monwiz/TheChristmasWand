extends Area2D

@export var scene_path: String
@export var new_music: AudioStream
@onready var anim: AnimationPlayer = get_parent().get_node("Fading")

func _on_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player":
		anim.play("fade-out")
		await anim.animation_finished
		if new_music:
			BGM.play_calm(new_music)
		get_tree().change_scene_to_file(scene_path)
