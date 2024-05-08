extends Area2D


<<<<<<< HEAD:Scripts/Shake.gd
onready var radius = $Area2D/CollisionShape2D.shape.radius
onready var SHAKE_SOUND = $Shake


func on_cast(_caster):
	var _c = $AnimatedSprite.connect("animation_finished", self, "animation_finished")
	var __c = $AnimatedSprite.play("default")
	Player.MusicPlayer.PlayOnNode(SHAKE_SOUND, Player)
	




func animation_finished():
	
	for body in $Area2D.get_overlapping_bodies():
=======
export var TagToBreak := ""


func break_tiles():
	for body in get_overlapping_bodies():
>>>>>>> 0ac80e42295ab507043cf95343afad113e369356:Scripts/Triggerables/BreakTiles.gd
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
