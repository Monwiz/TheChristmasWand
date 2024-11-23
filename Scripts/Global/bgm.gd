extends Node

@onready var calm: AudioStreamPlayer = $Calm
@onready var prebattle: AudioStreamPlayer = $PreBattle
@onready var battle: AudioStreamPlayer = $Battle
@onready var anim: AnimationPlayer = $AnimationPlayer

func play_calm(music: AudioStream):
	calm.stream = music
	calm.play()
	
func battle_start(premusic: AudioStream, loop: AudioStream):
	calm.playing = false
	
	prebattle.stream = premusic
	prebattle.play()
	await prebattle.finished
	
	battle.stream = loop
	battle.play()
	
func battle_end():
	calm.playing = true
	
	anim.play("battle_to_calm")
	await anim.animation_finished
	
	battle.playing = false
	battle.volume_db = 0
