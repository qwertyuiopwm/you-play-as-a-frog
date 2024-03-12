extends Node2D


export var CurrEffects = []

func _process(delta):
	CurrEffects = get_effects()
	
	for effect in CurrEffects:
		effect.affect(get_parent(), delta)

func Cure(cured_effect):
	for effect in get_effects():
		if effect is cured_effect.instance().get_script():
			effect.on_effect_removed(get_parent())
			effect.queue_free()


func Afflict(effect, duration: float):
	var new_effect = effect.instance()
	
	if not new_effect.CAN_STACK and has_effect(effect):
		if new_effect.STACK_TIME: 
			add_time(effect, effect.duration if duration <= 0 else duration)
		new_effect.queue_free()
		return
	
	add_child(new_effect)
	
	if duration < 0: return
	new_effect.duration = duration


func get_effects():
	return get_children()


func has_effect(effect):
	for _effect in get_effects():
		if _effect is effect.instance().get_script():
			return true
	
	return false


func add_time(effect, time):
	for _effect in get_effects():
		if _effect is effect.instance().get_script():
			_effect.duration += time
