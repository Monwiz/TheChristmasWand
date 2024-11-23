extends Panel

var current_dialogue = null
var current_line = 0
signal returned(action)
signal finished()

func _ready() -> void:
	$"../../ClickDetection".connect("button_down",next_line)

func _process(delta: float) -> void:
	#typewriter, idk
	if not $Dialogue.visible_ratio >= 1:
		$Dialogue.visible_characters += 1

func set_dialogue(to_dialogue:Dialogue):
	#sets the dialogue
	current_line = 0
	current_dialogue = to_dialogue
	toggle_panel(true)
	$"/root/Scene/Player".set_physics_process(false)
	next_line()

func next_line():
	print("A")
	$Dialogue.visible_characters = 0
	if current_dialogue == null:
		return
	#sets the name and dialogue label text to their corresponding name and lines
	if current_line >= current_dialogue.dialogue_line.size():
		end_dialogue()
	else:
		var element = current_dialogue.dialogue_line[current_line]
		if element is Dictionary:
			#switches the current dialogue to the picked dialogue
			$"../Choices".choices(element)
			$"../Choices".visible = true
			#$"../../ClickDetection".mouse_filter = MOUSE_FILTER_IGNORE
			toggle_panel(false)
		elif element is Array:
			#passes the data from the dialogue to the labels
			$Name.text = element[0]
			$Dialogue.text = element[1]
			current_line += 1
		elif element is Fight:
			toggle_panel(false)
			$"../../Battle".start_fight(element)
		else:
			returned.emit(element)
			current_line += 1
			next_line()

func toggle_panel(toggle):
	visible = toggle
	if toggle:
		#mouse_filter = MOUSE_FILTER_STOP
		$"../../ClickDetection".grab_focus()
	else:
		current_dialogue = null
		#mouse_filter = MOUSE_FILTER_PASS
		finished.emit()
		
func end_dialogue():
	toggle_panel(false)
	$"/root/Scene/Player".skip_iteration()
	$"/root/Scene/Player".set_physics_process(true)

func branch_dialogue(_dialogue):
	#$"../../ClickDetection".mouse_filter = MOUSE_FILTER_PASS
	if not _dialogue == null:
		$"../../ClickDetection".grab_focus()
		set_dialogue(_dialogue)
	else:
		print("It Works")
		current_line = 0
		toggle_panel(false)
