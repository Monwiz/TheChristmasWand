extends VBoxContainer

var held_dialogue

func choices(dictionary:Dictionary):
	held_dialogue = dictionary
	for choices in dictionary:
		var button = Button.new()
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
		button.name = choices
		button.text = choices
		add_child(button)
		button.connect("button_down",Callable(picked).bind(choices))

func picked(_name):
	visible = false
	$"../DialogueBox".branch_dialogue(held_dialogue[_name])
	for child in get_children():
		child.queue_free()
	
