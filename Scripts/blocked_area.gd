extends StaticBody2D
class_name BlockedArea

@export var event_conditions: Array[String]
@export var dialogue: Dialogue
@onready var dialogue_box : Panel = $/root/Scene/Gui/DialogueRelevant/DialogueBox

func _ready() -> void:
	update()

func update() -> void:
	if event_conditions.size() == 0: return
	if event_conditions.all(func(event):
		return event in WorldStats.PlotEventsHappened
	):
		queue_free()

func interact():
	await get_tree().physics_frame
	if is_queued_for_deletion(): return
	
	dialogue_box.set_dialogue(dialogue)
