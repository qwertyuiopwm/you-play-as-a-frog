extends "res://Scripts/Effect.gd"


func on_affect(entity, _delta):
	entity.sliding = true


func on_effect_removed(entity):
	entity.sliding = false
