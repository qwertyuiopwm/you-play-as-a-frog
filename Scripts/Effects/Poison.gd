extends "res://Scripts/BaseScripts/Effect.gd"


export var DPS = 3


func on_affect(entity, delta):
	entity.Hurt(DPS * delta)
	print(DPS * delta)
