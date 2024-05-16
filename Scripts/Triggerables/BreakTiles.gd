extends Area2D


export(Array, String) var TagsToBreak = []


func break_tiles():
	if not TagsToBreak:
		print(get_path(), " BreakTiles trying to break without any tags! ")
		return
	
	for body in get_overlapping_bodies():
		if not body is TileMap:
			continue
			
		if body.is_in_group("ground"):
			continue
		
		var tiles = body.get_used_cells()
		
		for tile_pos in tiles:
			var tile_id = body.get_cellv(tile_pos)
			
			if tile_id == -1:
				continue
			
			var tileName = body.tile_set.tile_get_name(tile_id)
			
			if not has_breakable_tag(tileName):
				continue
			
			var tile_global_pos = body.map_to_world(tile_pos)
			
			var shape = $CollisionShape2D.shape
			
			if shape is RectangleShape2D:
				var rect = Rect2(global_position - shape.extents, shape.extents * 2)
				if not rect.has_point(tile_global_pos + body.global_position):
					continue
			
			elif shape is CircleShape2D:
				var dist_to_tile = $CollisionShape2D.global_position.distance_to(tile_global_pos + body.global_position)
				if dist_to_tile > shape.radius:
					continue
			
			else:
				print(typeof(shape), " is not an accepted shape in ", self)
				continue
			
			body.set_cellv(tile_pos, -1)


func has_breakable_tag(tile_name):
	for tagToBreak in TagsToBreak:
		if tagToBreak in tile_name:
			return true
	return false
