extends "res://Scripts/Effect.gd"


func on_affect(entity, _delta):
	entity.can_move = false


func on_effect_removed(entity):
	entity.can_move = true
