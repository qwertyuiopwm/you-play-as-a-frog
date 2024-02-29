extends Node2D

export var TRIGGER_ON_START = false
export var State = false


func _ready():
	if not TRIGGER_ON_START: return
	trigger(State)


func trigger(trigger: bool):
	onTriggerAny(trigger)
	if State == trigger: return
	
	onTrigger(trigger)


func onTriggerAny(trigger: bool):
	pass

func onTrigger(trigger: bool):
	pass
