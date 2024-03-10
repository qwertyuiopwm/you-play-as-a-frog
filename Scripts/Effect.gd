extends Node2D


export var duration := 5.0
export var CAN_STACK = false
export var STACK_TIMES = false

func affect(entity, delta):
	duration -= delta
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()
		return
	on_affect(entity, delta)


func on_affect(entity, delta):
	pass

func on_effect_removed(entity):
	pass
