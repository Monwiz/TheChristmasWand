extends GPUParticles2D

func _ready() -> void:
	check_settings()

func check_settings():
	emitting = WorldStats.ParticledEnabled
