extends CharacterBody2D

const SPEED = 200.0
const STRENGTH = 10
const DEFENSE_ABILITY = 3
var outline = preload("res://Assets/Other/friend_outline.tres")
var goal_outline = preload("res://Assets/Other/goal_outline.tres")
var defense: int = 1

signal dead()

func _ready() -> void:
	$HealthBar.value = Stats.player_hp

func _physics_process(delta: float) -> void:
	var direction_x = Input.get_axis("ui_left", "ui_right")
	var direction_y = Input.get_axis("ui_up", "ui_down")
	if direction_x or direction_y:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func hurt(val: int) -> void:
	Stats.player_hp -= val / defense
	$HealthBar.value = Stats.player_hp
	if Stats.player_hp <= 0:
		dead.emit()

func get_hp() -> int:
	return Stats.player_hp

func add_hp(val: int) -> void:
	Stats.player_hp = min(Stats.player_hp + val, Stats.PLAYER_MAX_HP) #increase until the player's max hp
	$HealthBar.value = Stats.player_hp
	if Stats.player_hp <= 0:
		dead.emit()

func set_defense(val: int):
	defense = val
	
func get_defense_ability() -> float:
	return DEFENSE_ABILITY
	
func attack(entity: CharacterBody2D, multiplyer: float = 1.0) -> void:
	entity.hurt(STRENGTH * multiplyer * randf_range(0.8, 1.5) * ([1.5, 2, 3].pick_random() if randi_range(1, 4) == 1 else 1))
	#entity's strength * battle multiplyer (you can increase it for example by using spells) * basic random * critical hit random
	
func set_hover(val: bool) -> void:
	$Sprite.set("material", outline if val else null)

func set_hover_selected(val: bool) -> void: 
	$Sprite.set("material", goal_outline if val else null)
