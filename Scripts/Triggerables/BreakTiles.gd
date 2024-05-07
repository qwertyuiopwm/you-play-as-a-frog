extends Area2D


export var TagToBreak := ""


func break_tiles():
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
			
			if not TagToBreak in body.tile_set.tile_get_name(tile_id):
				continue
			
			var tile_global_pos = body.map_to_world(tile_pos)
			
			var shape = $CollisionShape2D.shape
			
			if shape is RectangleShape2D:
				var rect = Rect2(global_position - shape.extents, shape.extents * 2)
				if not rect.has_point(tile_global_pos + body.global_position):
					continue
			
			elif shape is CircleShape2D:
				var dist_to_tile = global_position.distance_to(tile_global_pos + body.global_position)
				if dist_to_tile > shape.radius:
					continue
			
			else:
				print(typeof(shape), " is not an accepted shape in ", self)
				continue
			
			body.set_cellv(tile_pos, -1)
