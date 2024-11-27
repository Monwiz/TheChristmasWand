extends Panel

var openable = true

func _ready() -> void:
	Stats.menu = $"."


func open():
	if not openable:
		return
	$"..".visible = true
	update_inventory()
	update_allies()

func close():
	$"..".visible = false

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
		print(item_list[i])
		
		if item_list[i][0] == -1:
			var icon = ImageTexture.create_from_image(Image.load_from_file(item_list[i][1].icon))
			icon.set_size_override(Vector2i(64,64))
			$InvList.add_item(i,icon)
		else:
			for n in item_list[i][0]:
				var icon = ImageTexture.create_from_image(Image.load_from_file(item_list[i][1].icon))
				icon.set_size_override(Vector2i(64,64))
				$InvList.add_item(i,icon)

func update_allies():
	pass
