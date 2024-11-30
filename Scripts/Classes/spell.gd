extends Resource
class_name Spell

@export var name: String
@export_multiline var description: String
var type: Types
var button: Button

enum Types { SIMPLE, DEACTIVATABLE, SWITCHABLE }
