extends "res://Scripts/BaseScripts/InstantSpell.gd"


onready var radius = $Area2D/CollisionShape2D.shape.radius


func on_cast(_caster):
	var _c = $AnimatedSprite.connect("frame_changed", self, "shake_if_time")
	var __c = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	var ___c = $AnimatedSprite.play("default")


func shake_if_time():
	if not $AnimatedSprite.frame == 4:
		return
	for body in $Area2D.get_overlapping_bodies():
		if not body is TileMap:
			continue
			
		if body.is_in_group("ground"):
			continue
		
		var tiles = body.get_used_cells()
		
		for tile_pos in tiles:
			var tile_id = body.get_cellv(tile_pos)
			
			if tile_id == -1:
				continue
			
			if not "(shake)" in body.tile_set.tile_get_name(tile_id):
				continue
			
			var tile_global_pos = body.map_to_world(tile_pos)
			var dist_to_tile = global_position.distance_to(tile_global_pos + body.global_position)
			if dist_to_tile > radius:
				continue
			
			body.set_cellv(tile_pos, -1)
