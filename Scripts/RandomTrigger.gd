extends "res://Scripts/Trigger.gd"


export var MIN_TIME: float
export var MAX_TIME: float

var timer: float = 0
onready var time_diff = MAX_TIME - MIN_TIME


func _process(delta):
	if not Enabled: return
	
	timer -= delta
	
	if timer > 0:
		return
	
	trigger(TriggerVal)
	
	timer = (randf() * time_diff) + MIN_TIME
