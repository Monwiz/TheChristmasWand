extends Area2D
class_name npc

@export var dialogue : Dialogue
@export var dialogue_box : Panel #make this automatic

func fetch_dialogue(body):
	dialogue_box.set_dialogue(dialogue)
