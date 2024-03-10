extends KinematicBody2D


func Afflict(effect, duration: float=-1):
	$EffectManager.Afflict(effect, duration)

func Cure(effect):
	$EffectManager.Cure(effect)
