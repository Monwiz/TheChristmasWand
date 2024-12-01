extends Panel

var openable = true
var menu_open = false

func _ready() -> void:
	$"../Back".connect("button_down",close)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		if menu_open:
			close()
		else:
			open()

func open():
	menu_open = true
	if not openable:
		return
	$"..".visible = true
	update_inventory()
	update_allies("open")
	Stats.player.set_physics_process(false)
	Stats.player.velocity = Vector2.ZERO
	$"/root/Scene/Gui/ChristmasWand".set_physics_process(false)
	if $InvList.item_count != 0:
		$InvList.grab_focus()
		$InvList.select(0)
	else:
		$"../Back".grab_focus()

func close():
	menu_open = false
	$"..".visible = false
	update_allies("close")
	Stats.player.set_physics_process(true)
	$"/root/Scene/Gui/ChristmasWand".set_physics_process(true)

func update_inventory():
	$InvList.clear()
	var item_list = {}
	for i in Stats.inventory:
		if item_list.has(i.name) and not i.stackable:
			item_list[i.name][0] += 1
		elif i.stackable:
			item_list[i.name] = [-1,i]
		else:
			item_list[i.name] = [0,i]
	for i in item_list:
		
		if item_list[i][0] == -1:
			var icon = ImageTexture.create_from_image(Image.load_from_file(item_list[i][1].icon))
			icon.set_size_override(Vector2i(64,64))
			$InvList.add_item(i,icon)
		else:
			for n in item_list[i][0]:
				var icon = ImageTexture.create_from_image(Image.load_from_file(item_list[i][1].icon))
				icon.set_size_override(Vector2i(64,64))
				$InvList.add_item(i,icon)

func update_allies(mode):
	match mode:
		"close":
			Stats.player.get_node("HealthBar").visible = false
			Stats.player.get_node("MagicBar").visible = false
			Stats.player.get_node("Label").visible = false
		"open":
			Stats.player.get_node("HealthBar").visible = true
			Stats.player.get_node("MagicBar").visible = true
			Stats.player.get_node("Label").visible = true
