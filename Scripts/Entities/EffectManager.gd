extends Node2D


export(Color) var SLIPPY_COLOR_MODULATE = Color(1, 1, 0.8)
export(Color) var POISON_COLOR_MODULATE = Color(1, 0.8, 1)

export var CurrEffects = []


class effect_sorter:
	static func sort_effects(a, b): 
		return a.duration < b.duration


func _process(delta):
	if visible:
		get_parent().modulate = get_parent_modulate()
	else:
		get_parent().modulate = Color(255, 255, 255)
	
	CurrEffects = get_effects()
	
	CurrEffects.sort_custom(effect_sorter, "sort_effects")
	
	for effect in CurrEffects:
		effect.affect(get_parent(), delta)


func Cure(cured_effect):
	for effect in get_effects():
		if effect is cured_effect.instance().get_script():
			effect.on_effect_removed(get_parent())
			effect.queue_free()


func Afflict(effect: PackedScene, duration: float, stacks=1):
	if has_effect(effect):
		var _effect = get_node("%s" % effect.instance().name)
		_effect.stack(duration, stacks)
		return
	
	var new_effect = effect.instance()
	if effect in get_parent().PERMANENT_EFFECTS:
		new_effect.Permanent = true
	
	new_effect.stacks = stacks
	
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


func get_parent_modulate():
	var mod = Color(1, 1, 1)
	
	if has_effect(Effects.slippy):
		mod *= SLIPPY_COLOR_MODULATE
	if has_effect(Effects.poison):
		mod *= POISON_COLOR_MODULATE
	
	return mod
