extends KinematicBody2D
class_name Entity


export(Array, PackedScene) var IMMUNITIES = []
export(Array, PackedScene) var PERMANENT_EFFECTS = []

onready var curr_immunities = IMMUNITIES

var sliding = false
var can_move = true
var slowness_mult: float = 1


func is_sliding():
	return sliding or has_effect(Effects.slippy)


func Afflict(effect, duration: float=-1, stacks=1, override_immunities:=false):
	if effect in curr_immunities and not override_immunities: return
	$EffectManager.Afflict(effect, duration, stacks)

func Cure(effect):
	$EffectManager.Cure(effect)

func has_effect(effect):
	return $EffectManager.has_effect(effect)

func has_immunity(immunities):
	if not immunities is Array:
		immunities = [immunities]
	
	for immunity in immunities:
		if immunity in curr_immunities:
			return true
	return false
