extends CharacterBody2D

const SPEED = 200.0
const STRENGTH = 30
const DEFENSE_ABILITY = 3
var outline = preload("res://Assets/Other/friend_outline.tres")
var goal_outline = preload("res://Assets/Other/goal_outline.tres")
var defense: int = 1
var skipping_iteration: bool = false
var menu_open = false
@onready var ray: RayCast2D = $RayCast2D
@onready var spell_ray: RayCast2D = $SpellRay

signal dead()

func _ready() -> void:
	$AnimatedSprite2D.pause()
	$HealthBar.value = Stats.player_hp
	if Stats._new_position != Vector2.ZERO:
		global_position = Stats._new_position
	Stats.player = $"."
	if "1.1.wand" in WorldStats.PlotEventsHappened:
		$Wand.visible = true

func _physics_process(delta: float) -> void:
	if skipping_iteration:
		skipping_iteration = false
		return
	
	## 4-way movement
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"): 
		var direction_x = Input.get_axis("ui_left", "ui_right")
		velocity.x = direction_x * SPEED
		if direction_x > 0:
			ray.target_position.x = 12
			spell_ray.target_position.x = 96
		else:
			ray.target_position.x = -12
			spell_ray.target_position.x = -96
		$AnimatedSprite2D.play()
		
		velocity.y = move_toward(velocity.y, 0, SPEED)
		ray.target_position.y = 0
		spell_ray.target_position.y = 0
	elif Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		var direction_y = Input.get_axis("ui_up", "ui_down")
		velocity.y = direction_y * SPEED
		if direction_y > 0:
			ray.target_position.y = 12
			spell_ray.target_position.y = 96
		else:
			ray.target_position.y = -12
			spell_ray.target_position.y = -96
		$AnimatedSprite2D.play()
			
		velocity.x = move_toward(velocity.x, 0, SPEED)
		ray.target_position.x = 0
		spell_ray.target_position.x = 0
		
		
	elif Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$AnimatedSprite2D.pause()
		
		var direction_y = Input.get_axis("ui_up", "ui_down")
		if direction_y:
			velocity.y = direction_y * SPEED
			if direction_y > 0:
				ray.target_position.y = 12
				spell_ray.target_position.y = 96
			else:
				ray.target_position.y = -12
				spell_ray.target_position.y = -96
			$AnimatedSprite2D.play()
	elif Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
		velocity.y = move_toward(velocity.y, 0, SPEED)
		$AnimatedSprite2D.pause()
		
		var direction_x = Input.get_axis("ui_left", "ui_right")
		if direction_x:
			velocity.x = direction_x * SPEED
			if direction_x > 0:
				ray.target_position.x = 12
				spell_ray.target_position.x = 96
			else:
				ray.target_position.x = -12
				spell_ray.target_position.x = -96
			$AnimatedSprite2D.play()
				
	move_and_slide()
			
	for i in get_slide_collision_count(): #Moving objects, like snow and ice blocks in the puzzles
		var collision = get_slide_collision(i)
		var obj = collision.get_collider()
		if obj is RigidBody2D:
			obj.apply_central_impulse(-20*collision.get_normal())
		elif obj is BlockedArea:
			await obj.update()
			if not obj.is_queued_for_deletion():
				velocity = collision.get_normal()
				obj.interact()
	
	if Input.is_action_just_pressed("ui_accept"):
		if ray.is_colliding():
			var collider = ray.get_collider()
			if collider.has_method("interact"):
				collider.interact(self)
				

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
	
func skip_iteration():
	skipping_iteration = true
	
func attack(entity: CharacterBody2D, multiplyer: float = 1.0) -> void:
	$AnimatedSprite2D.play("attacking")
	entity.hurt(STRENGTH * multiplyer * randf_range(0.8, 1.5) * ([1.5, 2, 3].pick_random() if randi_range(1, 4) == 1 else 1))
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("walking")
	$AnimatedSprite2D.pause()
	#entity's strength * battle multiplyer (you can increase it for example by using spells) * basic random * critical hit random
	
func set_hover(val: bool) -> void:
	$AnimatedSprite2D.set("material", outline if val else null)

func set_hover_selected(val: bool) -> void: 
	$AnimatedSprite2D.set("material", goal_outline if val else null)
