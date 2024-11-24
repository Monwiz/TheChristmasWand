extends StaticBody2D

@onready var dialogue_box : Panel = $/root/Scene/Gui/DialogueRelevant/DialogueBox

func _ready() -> void:
	if WorldStats.PlayerMailboxNew:
		$AnimatedSprite2D.play("new")
		
func interact(player):
	if WorldStats.PlayerMailboxNew:
		dialogue_box.set_dialogue(preload("res://Assets/Resources/Dialogue/Objects/player_mailbox_new.tres"))
		await dialogue_box.finished
		WorldStats.PlayerMailboxNew = false
		$AnimatedSprite2D.play("default")
	else:
		dialogue_box.set_dialogue(preload("res://Assets/Resources/Dialogue/Objects/player_mailbox.tres"))
