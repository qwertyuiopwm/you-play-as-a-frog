extends Node2D


export var Effects = []

func _process(delta):
	Effects = get_effects()
	
	for effect in Effects:
		effect.affect(get_parent(), delta)

func Cure(cured_effect):
	for effect in get_effects():
		if effect is cured_effect:
			effect.queue_free()


func Afflict(effect, duration: float):
	var new_effect = effect.instance()
	
	add_child(new_effect)
	
	if duration < 0: return
	new_effect.duration = duration


func get_effects():
	return get_children()
