extends VBoxContainer

var held_dialogue
var last_dialogue
var ignore_input: bool = false

func _physics_process(delta: float) -> void:
	if last_dialogue:
		if not ignore_input and Input.is_action_just_pressed("ui_cancel"):
			picked("_")
	ignore_input = false
	

func choices(dictionary:Dictionary):
	held_dialogue = dictionary.duplicate()
	if held_dialogue.has("_"):
		self.last_dialogue = held_dialogue["_"]
		held_dialogue.erase("_")
	for choices in held_dialogue:
		var button = Button.new()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.name = choices
		button.text = choices
		add_child(button)
		button.connect("button_down",Callable(picked).bind(choices))
	get_children()[0].grab_focus()
	ignore_input = true

func picked(_name):
	visible = false
	if _name != "_":
		$"../DialogueBox".branch_dialogue(held_dialogue[_name])
	else:
		$"../DialogueBox".branch_dialogue(last_dialogue)
	last_dialogue = null
	for child in get_children():
		child.queue_free()
