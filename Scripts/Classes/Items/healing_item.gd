@tool extends Item
class_name HealingItem

@export_enum("Number","% of the max health") var calculation_type = 0:
	set(value):
		print("test")
		if value == calculation_type: return
		calculation_type = value
		notify_property_list_changed()
		
var health_value

func _get_property_list(): #the godot stuff to change the type of the health_value variable
	#if Engine.is_editor_hint(): #commented because the item's duplicate function doesn't work with this uncommented
		var ret = []
		if calculation_type == 0:
			ret.append({
				"name": &"health_value",
				"type": TYPE_INT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE
			})
		else:
			ret.append({
				"name": &"health_value",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_STORAGE,
				"hint": PROPERTY_HINT_RANGE,
				"hint_string": "0,1,0.01"
			})
		return ret

	
func _init() -> void:
	type = Types.CONSUMABLE
	super._init() #go to the inherited class'es _init() func
	
func use_on(allie: CharacterBody2D):
	if calculation_type == 0:
		allie.add_hp(health_value)
	else:
		allie.add_hp(allie.get_max_hp() * health_value)
	Stats.remove_item(self)
