#I think it'd be better to split this into the usual dialogue script and actions/event script
extends Panel

var current_dialogue = null
var current_line = 0
signal returned(action)
signal finished()

func _ready() -> void:
	$"../../ClickDetection".connect("button_down",press)
	
func press():
	if not $Dialogue.visible_ratio >= 1:
		$Dialogue.visible_ratio = 1
	else:
		next_line()

func _process(delta: float) -> void:
	#typewriter, idk
	if not $Dialogue.visible_ratio >= 1:
		$Dialogue.visible_characters += 1

func set_dialogue(to_dialogue:Dialogue):
	#sets the dialogue
	current_line = 0
	current_dialogue = to_dialogue
	toggle_panel(true)
	Stats.player.set_physics_process(false)
	$"/root/Scene/Gui/Menu/Inventory".set_physics_process(false)
	$"/root/Scene/Gui/ChristmasWand".set_physics_process(false)
	$Dialogue.visible_characters = 0
	next_line()

func next_line():
	if current_dialogue == null:
		return
	$"../../ClickDetection".disconnect("button_down",press)
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
			$Dialogue.visible_characters = 0
		elif element is Array:
			#passes the data from the dialogue to the labels
			$Name.text = element[0]
			$Dialogue.text = element[1]
			current_line += 1
			$Dialogue.visible_characters = 0
		elif element is Fight:
			toggle_panel(false)
			$"../../Battle".start_fight(element)
			current_line += 1
			next_line()
		elif element is Texture:
			$"../../Picture".texture = element
			current_line += 1
			next_line()
		elif element is String:
			var str_split = element.split(".")
			match str_split[0]:
				"anim":
					match str_split[1]:
						"await":
							$/root/Scene/AnimationPlayer.play(str_split[2])
							await $/root/Scene/AnimationPlayer.animation_finished
						"continue":
							$/root/Scene/AnimationPlayer.play(str_split[2])
				"pic":
					match str_split[1]:
				#		"next":
				#			$/root/Scene/Gui/Picture.next()
						"hide":
							$/root/Scene/Gui/Picture.texture = null
				"timer":
					await get_tree().create_timer(float(str_split[1])).timeout
				_:
					returned.emit(element)
					WorldStats.action.emit(element)
			current_line += 1
			next_line()
		else:
			returned.emit(element)
			WorldStats.action.emit(element)
			current_line += 1
			next_line()
	$"../../ClickDetection".connect("button_down",press)

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
	$"../../Picture".texture = null
	$"/root/Scene/Player".skip_iteration()
	$"/root/Scene/Player".set_physics_process(true)
	if not $"/root/Scene/Gui/Battle".visible:
		$"/root/Scene/Gui/Menu/Inventory".set_physics_process(true)
		$"/root/Scene/Gui/ChristmasWand".set_physics_process(true)
	
	$Name.text = " "
	$Dialogue.text = " "

func branch_dialogue(_dialogue):
	#$"../../ClickDetection".mouse_filter = MOUSE_FILTER_PASS
	if not _dialogue == null:
		$"../../ClickDetection".grab_focus()
		set_dialogue(_dialogue)
	else:
		print("It Works")
		current_line = 0
		toggle_panel(false)
