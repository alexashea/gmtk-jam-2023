class_name Hero
extends CharacterBody2D


var speed: int = 200

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0


func start(start_position: Vector2, goal_position: Vector2) -> void:
	position = start_position
	await get_tree().physics_frame
	set_movement_target(goal_position)


func move(vel: Vector2) -> void:
	if Input.is_action_pressed("ui_up"):
		vel += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		vel += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		vel += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		vel += Vector2.RIGHT

	if not vel == Vector2.ZERO:
		vel = vel.normalized()
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.set_flip_h(velocity.x < 0)
		velocity = vel * speed
	else:
		$AnimatedSprite2D.stop()


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target


func _physics_process(delta: float) -> void:
	print(navigation_agent.distance_to_target())
	if navigation_agent.is_navigation_finished():
		print("navigation finished")
		return

	print("navigating")
	var current_agent_position: Vector2 = global_position
	print("current: %s, %s" % [current_agent_position.x, current_agent_position.y])
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	print("next: %s, %s" % [next_path_position.x, next_path_position.y])

	var new_velocity: Vector2 = next_path_position - current_agent_position
	print("velocity: %s, %s" % [new_velocity.x, new_velocity.y])
	move(new_velocity)

	velocity = new_velocity
	move_and_slide()
