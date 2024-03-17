extends KinematicBody2D
class_name Entity


export(Array, PackedScene) var IMMUNITIES = []
export(Array, PackedScene) var PERMANENT_EFFECTS = []

var sliding = false
var can_move = true


func is_sliding():
	return sliding or has_effect(Effects.slippy)


func Afflict(effect, duration: float=-1):
	if effect in IMMUNITIES: return
	$EffectManager.Afflict(effect, duration)

func Cure(effect):
	$EffectManager.Cure(effect)

func has_effect(effect):
	return $EffectManager.has_effect(effect)
