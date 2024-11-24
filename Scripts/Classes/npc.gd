extends CharacterBody2D
class_name npc

@export var dialogue : Dialogue
@export var dialogue_box : Panel #make this automatic
@export var movement_type: Movement = Movement.None
enum Movement { None, Random, Exact, Follow }
@export var is_following: Node2D
@export var speed: float = 150
@onready var nav_ag: NavigationAgent2D = $NavigationAgent2D

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
	dialogue_box.set_dialogue(dialogue)

func follow(goal: Node2D):
	is_following = goal
	movement_type = Movement.Follow
