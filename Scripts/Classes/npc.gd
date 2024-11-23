extends CharacterBody2D
class_name npc

@export var dialogue : Dialogue
@export var dialogue_box : Panel #make this automatic

func interact(player: CharacterBody2D):
	dialogue_box.set_dialogue(dialogue)
