extends "res://Scripts/Item.gd"


func on_pickup(player):
	player.restoration_postions += 1
	queue_free()
