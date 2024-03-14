extends "res://Scripts/InstantSpell.gd"


onready var radius = $Area2D/CollisionShape2D.shape.radius


func on_cast(caster):
	$AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.play("default")


func animation_finished():
	
	for body in $Area2D.get_overlapping_bodies():
		print(body)
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
			if global_position.distance_to(tile_global_pos) > radius:
				continue
			
			body.set_cellv(tile_pos, -1)
	
	queue_free()
