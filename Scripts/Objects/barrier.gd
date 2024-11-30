extends Node2D

@export var buttons: Array[Area2D]
var buttons_states: Array[bool]

func _ready() -> void:
	for i in len(buttons):
		buttons_states.append(false)
		buttons[i].pressed.connect(func(): buttons_states[i] = true)
		buttons[i].released.connect(func(): buttons_states[i] = false)

func _process(delta: float) -> void:
	if buttons_states.all(func(state): return state):
		$BarrierClosed.enabled = false
		$BarrierOpened.enabled = true
	else:
		$BarrierClosed.enabled = true
		$BarrierOpened.enabled = false
