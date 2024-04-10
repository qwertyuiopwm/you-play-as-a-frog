extends Node2D

export(Color) var SLIPPY_COLOR_MODULATE = Color(1, 1, 0.8)
export var CurrEffects = []


class effect_sorter:
	func sort_effects(a, b): 
		return a.duration < b.duration


func _process(delta):
	
	get_parent().modulate = Color(1, 1, 1)
	
	if has_effect(Effects.slippy):
		get_parent().modulate = SLIPPY_COLOR_MODULATE
	
	CurrEffects = get_effects()
	
	CurrEffects.sort_custom(effect_sorter, "sort_effects")
	
	for effect in CurrEffects:
		effect.affect(get_parent(), delta)

func Cure(cured_effect):
	for effect in get_effects():
		if effect is cured_effect.instance().get_script():
			effect.on_effect_removed(get_parent())
			effect.queue_free()


func Afflict(effect, duration: float):
	var new_effect = effect.instance()
	if effect in get_parent().PERMANENT_EFFECTS:
		new_effect.Permanent = true
	
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


func has_effect(effects):
	if not effects is Array:
		effects = [effects]
		
	for effect in effects:
		for _effect in get_effects():
			if _effect is effect.instance().get_script():
				return true
		
		return false


func add_time(effect, time):
	for _effect in get_effects():
		if _effect is effect.instance().get_script():
			_effect.duration += time
