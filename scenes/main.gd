extends Node2D


var window_size: Vector2
var open_treasure_atlas_id := Vector2i(3, 19)
var closed_treasure_atlas_id := Vector2i(2, 19)
var gold: int = 100
var day: int = 1

var hero: Hero
var hero_start_position: Vector2
var hero_level: int = 1
var hero_scene: PackedScene = preload("res://scenes/hero.tscn")

var mob_scene: PackedScene = preload("res://scenes/mob.tscn")
var mob_list: Array[Mob]
var mob_start_positions: Array[Vector2] = [
	(Vector2(18.5, 10.5)) * 16,
	(Vector2(8, 8.5)) * 16,
	(Vector2(11.5, 6.5)) * 16,
	(Vector2(11.5, 10.5)) * 16,
	(Vector2(4.5, 10.5)) * 16,
	(Vector2(4.5, 6.5)) * 16,
]
var skeleton_cost: int = 60


func _ready() -> void:
	window_size = get_viewport().size

	var dungeon_rooms: Array[Node] = $Dungeon.get_children()
	var dungeon_size := Vector2.ZERO
	for i in dungeon_rooms.size():
		var tile_room: TileMap = dungeon_rooms[i]
		if tile_room:
			dungeon_size.x += tile_room.get_used_rect().size.x * tile_room.cell_quadrant_size
			if i == 0:
				dungeon_size.y += tile_room.get_used_rect().size.y * tile_room.cell_quadrant_size

	set_treasure_tile(true)

	hero_start_position = $Dungeon.position
	hero_start_position.y += dungeon_size.y / 2 + 16

	mob_list.resize(6)
	mob_list.fill(null)


func set_treasure_tile(closed: bool) -> void:
	var atlas_id: Vector2i = closed_treasure_atlas_id if closed else open_treasure_atlas_id
	var treasure_tile := Vector2i(3, -4)

	$Dungeon/Treasury.erase_cell(1, treasure_tile)
	$Dungeon/Treasury.set_cell(1, treasure_tile, $Dungeon/Treasury.tile_set.get_source_id(0), atlas_id)


func add_hero() -> void:
	var treasure_position := (Vector2(18.5, 6)) * 16

	hero = hero_scene.instantiate()
	add_child(hero)

	hero.start(hero_start_position, treasure_position, hero_level)

	for i in range(mob_list.size()):
		var mob: Mob = mob_list[i]
		if not mob:
			continue
		mob.set_hero(hero)

	hero.found_treasure.connect(_on_hero_found_treasure)
	hero.escaped.connect(_on_hero_escaped)
	hero.died.connect(_on_hero_died)


func remove_hero() -> void:
	hero.found_treasure.disconnect(_on_hero_found_treasure)
	hero.escaped.disconnect(_on_hero_escaped)
	hero.died.disconnect(_on_hero_died)

	for i in range(mob_list.size()):
		var mob: Mob = mob_list[i]
		if not mob:
			continue
		mob.hero = null

	remove_child(hero)
	hero.queue_free()
	hero = null


func add_mob() -> bool:
	var index: int = mob_list.find(null)
	if index == -1:
		return false

	var mob: Mob = mob_scene.instantiate()
	add_child(mob)
	mob.start(mob_start_positions[index])
	mob_list[index] = mob
	return true


func reset_mobs() -> void:
	for i in range(mob_list.size()):
		var mob: Mob = mob_list[i]
		if not mob:
			continue
		if mob.health <= 0:
			remove_child(mob)
			mob.queue_free()
			mob_list[i] = null
			continue
		mob.start(mob.home_location)


func toggle_game_mode_for_mobs() -> void:
	for i in range(mob_list.size()):
		var mob: Mob = mob_list[i]
		if not mob:
			continue
		mob.toggle_game_mode()


func calculate_hero_level(hero_succeeded: bool) -> int:
	var new_level: float = hero_level + day
	new_level *= 1.1 if hero_succeeded else 0.9
	new_level = roundi(new_level)
	return max(new_level, 1)


func update_skeleton_button() -> void:
	var add_skeletons_button: Button = $HUD/AddSkeletonButton
	var has_max_skeletons = mob_list.find(null) == -1

	add_skeletons_button.disabled = has_max_skeletons or gold < skeleton_cost
	if has_max_skeletons:
		add_skeletons_button.text = "MAX SKELETONS"
	elif gold < skeleton_cost:
		add_skeletons_button.text = "NOT ENOUGH GOLD"
	else:
		add_skeletons_button.text = "BUY SKELETONS"

	add_skeletons_button.show()


func _on_hero_found_treasure():
	set_treasure_tile(false)
	var stolen_gold: int = min(roundi(gold * 0.2), gold)
	gold -= stolen_gold
	$HUD/CoinsLabel.text = "%sg" % gold
	hero.gold += stolen_gold
	# TODO: play theft sfx


func _on_hero_escaped() -> void:
	print("hero escaped")
	# TODO: play failure sfx
	hero.hide()

	hero_level = calculate_hero_level(true)

	$HUD/ManageButton.disabled = false
#	show_escape_message()


func _on_hero_died() -> void:
	print("hero died")
	# TODO: play success sfx
	gold += hero.gold
	$HUD/CoinsLabel.text = "%sg" % gold

	hero_level = calculate_hero_level(false)

	$HUD/ManageButton.disabled = false
#	show_success_message()


func _on_manage_button_pressed() -> void:
	day += 1
	$HUD/DayLabel.text = "Day %s" % day

	$HUD/ManageButton.hide()
	$HUD/FightButton.show()

	remove_hero()
	reset_mobs()
	toggle_game_mode_for_mobs()
	update_skeleton_button()
	set_treasure_tile(true)


func _on_fight_button_pressed() -> void:
	toggle_game_mode_for_mobs()

	$HUD/FightButton.hide()
	$HUD/AddSkeletonButton.hide()
	$HUD/ManageButton.disabled = true
	$HUD/ManageButton.show()
	
	add_hero()


func _on_add_skeleton_button_pressed() -> void:
	if add_mob():
		gold -= skeleton_cost
		$HUD/CoinsLabel.text = "%sg" % gold
		update_skeleton_button()
