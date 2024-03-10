extends Node2D


export var duration = 5

func affect(entity, delta):
	duration -= delta
	on_affect(entity, delta)
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()


func on_affect(entity, delta):
	pass

func on_effect_removed(entity):
	pass