extends KinematicBody2D


export var Effects = []

func _process(delta):
	for effect in Effects:
		if effect.affect():
			Effects.remove(effect)

