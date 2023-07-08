extends Node2D


var window_size: Vector2
var treasure_position := (Vector2(18.5, 4)) * 16
var open_treasure_atlas_id := Vector2i(3, 19)
var closed_treasure_atlas_id := Vector2i(2, 19)


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

#	var dungeon_scale: int = min(window_size.x/dungeon_size.x, window_size.y/dungeon_size.y)
#	print(window_size.x, ",", dungeon_size.x, ",", window_size.y, ",", dungeon_size.y, ",", dungeon_scale)
#	$Dungeon.apply_scale(Vector2(dungeon_scale, dungeon_scale))
#	dungeon_size *= dungeon_scale
#
#	$Dungeon.position.x = (window_size.x - dungeon_size.x) / 2
#	$Dungeon.position.y = window_size.y - dungeon_size.y

#	$Hero.apply_scale(Vector2(dungeon_scale, dungeon_scale))
	var hero_start_position: Vector2 = $Dungeon.position
	hero_start_position.y += dungeon_size.y / 2 + 16
	$Hero.start(hero_start_position, treasure_position)

	var mob_start_position := (Vector2(18.5, 8.5)) * 16
	$Mob.start(mob_start_position)
	$Mob.set_hero($Hero)
	$MobTimer.start()


func set_treasure_tile(closed: bool) -> void:
	var atlas_id: Vector2i = closed_treasure_atlas_id if closed else open_treasure_atlas_id
	var treasure_tile := Vector2i(3, -4)

	$Dungeon/Treasury.erase_cell(1, treasure_tile)
	$Dungeon/Treasury.set_cell(1, treasure_tile, $Dungeon/Treasury.tile_set.get_source_id(0), atlas_id)

	# TODO: play theft sfx


func _on_hero_found_treasure():
	set_treasure_tile(false)


func _on_mob_timer_timeout():
	$Mob.set_movement_target($Hero.global_position)
	$MobTimer.start()
