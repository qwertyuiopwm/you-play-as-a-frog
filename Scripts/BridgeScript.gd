extends Node2D


var complete = false


func _on_Area2D_body_entered(body):
	if complete: return
	if not body.is_in_group("Player"): return
	
	var item = body.held_big_item
	if not (item is Ladder): return
	
	complete = true
	body.held_big_item = null
	item.queue_free()
	$TileMap.set_cell(0, 0, 4)
