extends Node2D
class_name Ladder, "res://Items/Ladder.tscn"




func _on_Area2D_body_entered(body):
	if not body.is_in_group("player"): return
	if not body.held_big_item is Ladder: return
	
	body.held_big_item = null
	$TileMap.set_cell(0, 0, 4)
