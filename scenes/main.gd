extends Node2D


var window_size: Vector2


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

	var dungeon_scale: int = min(window_size.x/dungeon_size.x, window_size.y/dungeon_size.y)
	print(window_size.x, ",", dungeon_size.x, ",", window_size.y, ",", dungeon_size.y, ",", dungeon_scale)
	$Dungeon.apply_scale(Vector2(dungeon_scale, dungeon_scale))
	dungeon_size *= dungeon_scale

	$Dungeon.position.x = (window_size.x - dungeon_size.x) / 2
	$Dungeon.position.y = window_size.y - dungeon_size.y

	$Hero.apply_scale(Vector2(dungeon_scale, dungeon_scale))
	var hero_start_position: Vector2 = $Dungeon.position
	hero_start_position.y += dungeon_size.y / 2
	$Hero.start(hero_start_position, hero_start_position + Vector2(100, 0))
