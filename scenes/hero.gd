class_name Hero
extends Area2D


var speed: int = 200


func _process(delta: float) -> void:
	var velocity := Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity += Vector2.UP
	if Input.is_action_pressed("ui_down"):
		velocity += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		velocity += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		velocity += Vector2.RIGHT

	if not velocity == Vector2.ZERO:
		velocity = velocity.normalized()
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.set_flip_h(velocity.x < 0)
		position += velocity * speed * delta
	else:
		$AnimatedSprite2D.stop()

func start(start_position: Vector2) -> void:
	position = start_position

