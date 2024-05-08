extends "res://Scripts/BaseScripts/Item.gd"


func on_pickup(player):
	player.restoration_potions += 1
