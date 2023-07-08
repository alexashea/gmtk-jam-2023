class_name Hero
extends CharacterBody2D


signal found_treasure

var speed: int = 20
var has_treasure: bool = false
var exit_position: Vector2
var treasure_position: Vector2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 1.5
	navigation_agent.target_desired_distance = 1.5


func start(start_position: Vector2, goal_position: Vector2) -> void:
	exit_position = start_position
	treasure_position = goal_position
	position = start_position
	await get_tree().physics_frame
	set_movement_target(goal_position)


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func get_manual_movement() -> Vector2:	
	var manual_velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		manual_velocity += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		manual_velocity += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		manual_velocity += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		manual_velocity += Vector2.RIGHT
	return manual_velocity


func set_walk_animation() -> void:
	if not velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.set_flip_h(velocity.x < 0)
	else:
		$AnimatedSprite2D.stop()


func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		if not has_treasure:
			has_treasure = true
			set_movement_target(exit_position)
			found_treasure.emit()

		velocity = get_manual_movement().normalized() * speed
		set_walk_animation()
		move_and_slide()
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity += get_manual_movement()
	new_velocity = new_velocity.normalized() * speed

	velocity = new_velocity
	set_walk_animation()
	move_and_slide()
