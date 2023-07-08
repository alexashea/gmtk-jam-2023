class_name Hero
extends CharacterBody2D


signal found_treasure
signal escaped
signal hit_mob
signal died

var move_speed: int = 20
var has_treasure: bool = false
var exit_position: Vector2
var treasure_position: Vector2

var is_fighting: bool = false
var attack_speed: int = 4
var attack_time: float = max(11 - attack_speed, 1) / 4
var max_health: int = 50
var health: int = 50
var attack_strength: int = 10
var attacking_mob: Mob

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 1.5
	navigation_agent.target_desired_distance = 1.5


func _process(_delta: float) -> void:
	if health > 0 and not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")


func start(start_position: Vector2, goal_position: Vector2) -> void:
	exit_position = start_position
	treasure_position = goal_position
	position = start_position
	await get_tree().physics_frame
	set_movement_target(goal_position)


func set_movement_target(movement_target: Vector2) -> void:
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
		$AnimatedSprite2D.play("idle")


func attack() -> void:
	$AnimatedSprite2D.play("attack")
	attacking_mob.take_damage(attack_strength)
	$AttackTimer.start(attack_time)

	# in case of race condition shenanigans
	if health <= 0:
		$AnimatedSprite2D.play("death")


func take_damage(damage: int) -> void:
	health -= damage
	print("hero health %s" % health)
	if health <= 0:
		print("hero died")
		$AnimatedSprite2D.play("death")
		died.emit()


func _physics_process(_delta: float) -> void:
	if is_fighting or health <= 0:
		return

	if navigation_agent.is_navigation_finished():
		if not has_treasure:
			has_treasure = true
			set_movement_target(exit_position)
			found_treasure.emit()
		else:
			escaped.emit()

		velocity = get_manual_movement().normalized() * move_speed
		set_walk_animation()
		move_and_slide()
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity += get_manual_movement()
	new_velocity = new_velocity.normalized() * move_speed

	velocity = new_velocity
	set_walk_animation()
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var mob := area.get_parent() as Mob
	if mob and mob.health > 0:
		hit_mob.emit()
		$AnimatedSprite2D.play("idle")
		$AnimatedSprite2D.set_flip_h(global_position.x > mob.global_position.x)
		is_fighting = true
		attacking_mob = mob
		attacking_mob.fight()
		attack()
		$AttackTimer.start(attack_time)
		attacking_mob.died.connect(_on_mob_died)


func _on_attack_timer_timeout() -> void:
	if health > 0 && attacking_mob.health > 0:
		attack()


func _on_mob_died() -> void:
	is_fighting = false
	attacking_mob.died.disconnect(_on_mob_died)
