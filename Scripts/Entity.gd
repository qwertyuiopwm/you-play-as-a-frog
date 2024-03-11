extends KinematicBody2D
class_name Entity


var sliding = false
var can_move = true


func Afflict(effect, duration: float=-1):
	$EffectManager.Afflict(effect, duration)

func Cure(effect):
	$EffectManager.Cure(effect)
