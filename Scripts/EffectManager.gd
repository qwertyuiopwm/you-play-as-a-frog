extends Node2D


export var Effects = []

func _process(delta):
	Effects = get_effects()
	
	for effect in Effects:
		effect.affect(get_parent(), delta)

func cure(cured_effect):
	for effect in get_effects():
		if effect is cured_effect:
			effect.queue_free()

func get_effects():
	return get_children()
