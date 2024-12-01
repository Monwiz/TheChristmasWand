extends Area2D

@export var dialogue : Dialogue
@onready var dialogue_box : Panel = $/root/Scene/Gui/DialogueRelevant/DialogueBox
@export var event_string: String

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player": return
	if event_string in WorldStats.PlotEventsHappened:
		queue_free()
		return
	
	Stats.player.velocity = Vector2.ZERO
	WorldStats.PlotEventsHappened.append(event_string)
	dialogue_box.set_dialogue(dialogue)
	
