extends "res://Effects/Effect.gd"


var DPS = 3
var _DURATION = 5


func _init():
	DURATION = _DURATION


func on_affect(entity, delta):
	entity.health -= DPS * delta
