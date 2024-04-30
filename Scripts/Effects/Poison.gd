extends "res://Scripts/BaseScripts/Effect.gd"


export var DamagePerStack = .5


func on_affect(entity, delta):
	entity.hurt(DamagePerStack * stacks * delta)
