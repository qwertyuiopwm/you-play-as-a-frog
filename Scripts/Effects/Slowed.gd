extends "res://Scripts/BaseScripts/Effect.gd"


export var speed_multiplier = 0.5

var oldSpeed: int
func on_affect(entity, _delta):
	oldSpeed = entity.SPEED
	entity.SPEED = oldSpeed*speed_multiplier
	
func on_effect_removed(entity):
	entity.SPEED = oldSpeed
