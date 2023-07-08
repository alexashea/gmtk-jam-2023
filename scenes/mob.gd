class_name Mob
extends CharacterBody2D


signal died

var home_location: Vector2
var move_speed: int = 20

var is_fighting: bool = false
var attack_speed: int = 5
var attack_time: float = max(11 - attack_speed, 1) / 4
var max_health: int = 40
var health: int = 40
var attack_strength: int = 5
var hero: Hero

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	navigation_agent.path_desired_distance = 1.5
	navigation_agent.target_desired_distance = 1.5


func _process(_delta: float) -> void:
	if health > 0 and not $AnimatedSprite2D.is_playing():
		$AnimatedSprite2D.play("idle")


func start(start_position: Vector2) -> void:
	position = start_position
	home_location = start_position
	await get_tree().physics_frame


func set_hero(new_hero: Hero) -> void:
	hero = new_hero
	set_movement_target(hero.global_position)
	hero.hit_mob.connect(_on_hero_hit_mob)


func set_movement_target(movement_target: Vector2) -> void:
	navigation_agent.target_position = movement_target


func set_walk_animation() -> void:
	if not velocity == Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
		$AnimatedSprite2D.set_flip_h(velocity.x < 0)
	else:
		$AnimatedSprite2D.play("idle")


func fight() -> void:
	$AnimatedSprite2D.play("idle")
	is_fighting = true
	attack()
	$AttackTimer.start(attack_time)


func attack() -> void:
	$AnimatedSprite2D.play("attack")
	hero.take_damage(attack_strength)
	$AttackTimer.start(attack_time)

	# in case of race condition shenanigans
	if health <= 0:
		$AnimatedSprite2D.play("death")


func take_damage(damage: int) -> void:
	health -= damage
	print("mob health %s" % health)
	if health <= 0:
		print("mob died")
		$AnimatedSprite2D.play("death")
		died.emit()


func _physics_process(_delta: float) -> void:
	if (health <= 0 
			or not hero 
			or hero.health <= 0
			or hero.is_fighting):
		return

	if navigation_agent.is_navigation_finished():
		velocity = Vector2.ZERO
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized() * move_speed

	velocity = new_velocity
	set_walk_animation()
	move_and_slide()


func _on_hero_hit_mob() -> void:
	if health > 0:
		$AnimatedSprite2D.play("idle")


func _on_attack_timer_timeout() -> void:
	if health > 0 && hero.health > 0:
		attack()
