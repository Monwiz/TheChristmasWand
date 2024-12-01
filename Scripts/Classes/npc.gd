extends CharacterBody2D
class_name npc

@export var dialogue : Dialogue
@onready var dialogue_box : Panel = $/root/Scene/Gui/DialogueRelevant/DialogueBox
@export var movement_type: Movement = Movement.None
enum Movement { None, Random, Exact, Follow }
@export var is_following: Node2D
@export var speed: float = 150
@export var hp: int = 100
@export var strength: int = 20
var defense: int = 1
@export var defense_ability: float = 3

signal dead()

var outline = preload("res://Assets/Other/friend_outline.tres")
var goal_outline = preload("res://Assets/Other/goal_outline.tres")
@onready var nav_ag: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	$AnimatedSprite2D.pause()
	$HealthBar.max_value = hp
	$HealthBar.value = hp
	
func get_hp() -> int:
	return hp

func add_hp(val: int) -> void:
	hp = min(hp + val, $HealthBar.max_value) #increase until the player's max hp
	$HealthBar.value = hp
	if hp <= 0:
		dead.emit()

func hurt(val: int) -> void:
	hp -= val / defense
	$HealthBar.value = hp
	if hp <= 0:
		dead.emit()
		
func set_defense(val: int):
	defense = val
	
func get_defense_ability() -> float:
	return defense_ability
	
func attack(entity: CharacterBody2D, multiplyer: float = 1.0) -> void:
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.play("attacking")
	entity.hurt(strength * multiplyer * randf_range(0.8, 1.5) * ([1.5, 2, 3].pick_random() if randi_range(1, 4) == 1 else 1))
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("walking")
	$AnimatedSprite2D.pause()
	
func set_hover(val: bool) -> void:
	$AnimatedSprite2D.set("material", outline if val else null)
	
func set_hover_selected(val: bool) -> void: 
	$AnimatedSprite2D.set("material", goal_outline if val else null)
	
	
func _physics_process(delta: float) -> void:
	match movement_type:
		Movement.Exact:
			pass
		Movement.Follow:
			nav_ag.set_target_position(is_following.global_position)
			if not nav_ag.is_navigation_finished():
				var new_direction = global_position.direction_to(nav_ag.get_next_path_position())
				#snapped(8.123, 0.01) works the same as round(8.123, 2) in Python, outputs 8.12
				#snapped(8.123, 0.01) means 0.01 * int(8.123 / 0.01)
				if is_following.get_node("RayCast2D").target_position.x != 0:
					if snapped(abs(new_direction.y), 0.1) == 0:
						velocity.x = (ceil(new_direction.x) if new_direction.x > 0 else floor(new_direction.x)) * speed
						velocity.y = 0
					else:
						velocity.x = 0
						velocity.y = (ceil(new_direction.y) if new_direction.y > 0 else floor(new_direction.y)) * speed
				else:
					if snapped(abs(new_direction.x), 0.1) == 0:
						velocity.x = 0
						velocity.y = (ceil(new_direction.y) if new_direction.y > 0 else floor(new_direction.y)) * speed
					else:
						velocity.x = (ceil(new_direction.x) if new_direction.x > 0 else floor(new_direction.x)) * speed
						velocity.y = 0
			else:
				velocity = Vector2.ZERO
		Movement.Random:
			pass
			
	move_and_slide()

func interact(player: CharacterBody2D):
	if dialogue:
		Stats.player.velocity = Vector2.ZERO
		dialogue_box.set_dialogue(dialogue)

func follow(goal: Node2D):
	is_following = goal
	movement_type = Movement.Follow
