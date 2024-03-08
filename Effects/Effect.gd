

export var DURATION = 5

var duration_counter = 0

func affect(entity, delta):
	duration_counter += delta
	on_affect(entity, delta)
	if duration_counter >= DURATION:
		on_effect_remove(entity)


func on_affect(entity, delta):
	pass

func on_effect_remove(entity):
	pass
