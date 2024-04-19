extends Node2D


export var duration := 5.0
export var CAN_STACK = false
export var STACK_TIME = false
export var Permanent = false

func affect(entity, delta):
	duration -= delta * int(not Permanent)
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()
		return
	on_affect(entity, delta)


func on_affect(_entity, _delta):
	pass

func on_effect_removed(_entity):
	pass
