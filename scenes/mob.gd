class_name Mob
extends CharacterBody2D


signal found_treasure

var speed: int = 20
var is_fighting: bool = false

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 1.5
	navigation_agent.target_desired_distance = 1.5


func start(start_position: Vector2, goal_position: Vector2) -> void:
	position = start_position
	await get_tree().physics_frame
	set_movement_target(goal_position)


func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.target_position = movement_target


func set_walk_animation() -> void:
	if not velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.set_flip_h(velocity.x < 0)
	else:
		$AnimatedSprite2D.play("idle")


func fight() -> void:
	is_fighting = true
	$AnimatedSprite2D.play("attack")


func _physics_process(_delta: float) -> void:
	if is_fighting:
		return

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized() * speed

	velocity = new_velocity
	set_walk_animation()
	move_and_slide()
