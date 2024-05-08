extends "res://Scripts/BaseScripts/Effect.gd"


export var DamagePerStack = .5


func on_affect(entity, delta):
	var damage = DamagePerStack * stacks * delta
	entity.hurt(damage, true)
