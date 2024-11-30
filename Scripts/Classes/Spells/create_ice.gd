extends Spell

func _init() -> void:
	type = Types.DEACTIVATABLE
	set_button()
	
func set_button():
	button = Button.new()
	button.text = "Create an ice block"
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.custom_minimum_size.y = 32
	button.pressed.connect(use)
	
func update():
	var ray: RayCast2D = Stats.player.get_node("SpellRay")
	while ray.is_colliding():
		var obj = ray.get_collider()
		if obj is Spawner:
			button.disabled = false
			return
		else:
			ray.add_exception(obj)
			ray.force_raycast_update()
	button.disabled = true
			
func use():
	var ray: RayCast2D = Stats.player.get_node("SpellRay")
	while ray.is_colliding():
		var obj = ray.get_collider()
		if obj is Spawner:
			obj.spawn_ice()
			break
		else:
			ray.add_exception(obj)
			ray.force_raycast_update()
