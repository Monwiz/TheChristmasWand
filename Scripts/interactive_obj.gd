extends StaticBody2D

@export var dialogue : Dialogue
@onready var dialogue_box : Panel = $/root/Scene/Gui/DialogueRelevant/DialogueBox
@export var event_string: String

func _ready() -> void:
	if event_string in WorldStats.PlotEventsHappened:
		queue_free()

func interact(player) -> void:
	WorldStats.PlotEventsHappened.append(event_string)
	if dialogue:
		dialogue_box.set_dialogue(dialogue)
		queue_free()
