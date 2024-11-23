extends Resource
class_name Fight

@export_node_path("CharacterBody2D") var allies_paths: Array[NodePath] = ["Player"]
@export_node_path("CharacterBody2D") var enemies_paths: Array[NodePath]
@export var premusic: AudioStream = preload("res://Assets/Audio/Music/battle_intro.ogg")
@export var music: AudioStream = preload("res://Assets/Audio/Music/battle.ogg")
@export var battle_program: BattleProgram
@export var can_leave: bool = true
@export_range(0, 1, 0.01) var leaving_chances: float = 0.75

@export_group("Dialogue")
@export var talking_dialogue: Dialogue
@export var failed_leaving_dialogue: Dialogue
@export var dialogue_before_death: Dialogue
