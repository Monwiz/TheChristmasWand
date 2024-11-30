extends Panel

@onready var cont = $VBoxContainer

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open()
	
func open():
	update()
	visible = true
	Stats.player.set_physics_process(false)
	if cont.get_child_count() != 0:
		cont.get_children()[0].grab_focus()

func close():
	visible = false
	Stats.player.set_physics_process(true)

func update():
	for child in cont.get_children():
		cont.remove_child(child)
	for spell in Stats.interact_spells:
		if not spell.button:
			spell.set_button()
		var btn = spell.button
		if spell.type == Spell.Types.DEACTIVATABLE:
			spell.update()
		btn.pressed.connect(close)
		cont.add_child(btn)
		
func free() -> void:
	for child in cont.get_children():
		cont.remove_child(child)
