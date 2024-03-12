extends KinematicBody2D
class_name Entity


export(Array, PackedScene) var IMMUNITIES = []

var sliding = false
var can_move = true


func Afflict(effect, duration: float=-1):
	if effect in IMMUNITIES: return
	$EffectManager.Afflict(effect, duration)

func Cure(effect):
	$EffectManager.Cure(effect)
