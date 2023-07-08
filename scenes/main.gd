extends Node2D


var window_size: Vector2
var open_treasure_atlas_id := Vector2i(3, 19)
var closed_treasure_atlas_id := Vector2i(2, 19)
var hero_scene: PackedScene = preload("res://scenes/hero.tscn")
var mob_scene: PackedScene = preload("res://scenes/mob.tscn")
var mob_list: Array[Mob]


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

	var hero_start_position: Vector2 = $Dungeon.position
	hero_start_position.y += dungeon_size.y / 2 + 16
	add_hero(hero_start_position)

	mob_list.resize(6)
	mob_list.fill(null)

	add_mob()
#	add_mob()
#	add_mob()
#	add_mob()
#	add_mob()
#	add_mob()


func set_treasure_tile(closed: bool) -> void:
	var atlas_id: Vector2i = closed_treasure_atlas_id if closed else open_treasure_atlas_id
	var treasure_tile := Vector2i(3, -4)

	$Dungeon/Treasury.erase_cell(1, treasure_tile)
	$Dungeon/Treasury.set_cell(1, treasure_tile, $Dungeon/Treasury.tile_set.get_source_id(0), atlas_id)


func add_hero(start_position: Vector2) -> void:
	var treasure_position := (Vector2(18.5, 4)) * 16

	var hero: Hero = hero_scene.instantiate()
	add_child(hero)

	hero.start(start_position, treasure_position)

	hero.found_treasure.connect(_on_hero_found_treasure)
	hero.escaped.connect(_on_hero_escaped)
	hero.died.connect(_on_hero_died)


func add_mob() -> void:
	var mob_start_positions: Array[Vector2] = [
		(Vector2(18.5, 8.5)) * 16,
		(Vector2(8, 6.5)) * 16,
		(Vector2(11.5, 4.5)) * 16,
		(Vector2(11.5, 8.5)) * 16,
		(Vector2(4.5, 8.5)) * 16,
		(Vector2(4.5, 4.5)) * 16,
	]

	var index: int = mob_list.find(null)
	if index == -1:
		return

	var mob: Mob = mob_scene.instantiate()
	add_child(mob)
	mob.start(mob_start_positions[index])
	mob.set_hero($Hero)
	mob_list[index] = mob


func reset_mobs() -> void:
	for mob in mob_list:
		if mob:
			mob.set_movement_target(mob.home_location)


func _on_hero_found_treasure():
	set_treasure_tile(false)
#	var stolen_gold: int = min(roundi(gold * 0.1), gold)
#	gold -= stolen_gold
#	hero.gold += stolen_gold
	# TODO: play theft sfx


func _on_hero_escaped():
	print("hero escaped")
#	show_escape_message()
#	day += 1
#	hero_level = calculate_hero_level(true)
#	start_manage_phase()


func _on_hero_died():
	print("hero died")
#	gold += hero.gold
#	show_success_message()
#	day += 1
#	hero_level = calculate_hero_level(false)
#	start_manage_phase()
