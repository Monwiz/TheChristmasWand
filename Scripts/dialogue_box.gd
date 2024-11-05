extends Panel

var current_dialogue = null
var current_line = 0
func _ready() -> void:
	$"../../ClickDetection".connect("button_down",next_line)

func _process(delta: float) -> void:
	#typewriter, idk
	if not $Dialogue.visible_ratio >= 1:
		$Dialogue.visible_characters += 1

func set_dialogue(to_dialogue:dialogue):
	#sets the dialogue
	current_line = 0
	current_dialogue = to_dialogue
	toggle_panel(true)
	next_line()

func next_line():
	print("A")
	$Dialogue.visible_characters = 0
	if current_dialogue == null:
		return
	#sets the name and dialogue label text to their corresponding name and lines
	if current_line >= current_dialogue.dialogue_line.size():
		#turns off the dialogue box
		toggle_panel(false)
	elif current_dialogue.dialogue_line[current_line] is Dictionary:
		#switches the current dialogue to the picked dialogue
		$"../Choices".choices(current_dialogue.dialogue_line[current_line])
		$"../Choices".visible = true
		$"../../ClickDetection".mouse_filter = MOUSE_FILTER_IGNORE
		toggle_panel(false)
	else:
		#passes the data from the dialogue to the labels
		$Name.text = current_dialogue.dialogue_line[current_line][0]
		$Dialogue.text = current_dialogue.dialogue_line[current_line][1]
		current_line += 1

func toggle_panel(toggle):
	visible = toggle
	if toggle:
		mouse_filter = MOUSE_FILTER_STOP
	else:
		current_dialogue = null
		mouse_filter = MOUSE_FILTER_PASS

func branch_dialogue(_dialogue):
	$"../../ClickDetection".mouse_filter = MOUSE_FILTER_PASS
	if not _dialogue == null:
		set_dialogue(_dialogue)
	else:
		print("It Works")
		current_line = 0
		toggle_panel(false)
