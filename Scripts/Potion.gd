extends "res://Scripts/Item.gd"


func on_pickup(player):
	player.restoration_potions += 1
