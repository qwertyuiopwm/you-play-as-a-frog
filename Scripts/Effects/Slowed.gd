extends "res://Scripts/BaseScripts/Effect.gd"


export var speed_mult_per_stack = 0.9

func on_affect(entity, _delta):
	entity.slowness_mult = pow(speed_mult_per_stack, stacks)
	
func on_effect_removed(entity):
	entity.slowness_mult = 1
