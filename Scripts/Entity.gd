extends KinematicBody2D


func Afflict(effect, duration: int=-1):
	$EffectManager.Afflict(effect, duration)

func Cure(effect):
	$EffectManager.Cure(effect)
