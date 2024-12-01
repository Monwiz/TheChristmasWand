extends Control

func _ready() -> void:
	BGM.play_calm(load("res://Assets/Audio/Music/main_menu.ogg"))
	$Button.grab_focus()
	$TextureRect.modulate = Color.BLACK

func _on_button_pressed() -> void:
	$Fading.play("fade-out")
	await $Fading.animation_finished
	get_tree().change_scene_to_file("res://Scenes/1.1home.tscn")

func _on_check_button_toggled(toggled_on: bool) -> void:
	WorldStats.ParticledEnabled = not toggled_on


func _on_video_stream_player_finished() -> void:
	$TextureRect.modulate = Color.WHITE
