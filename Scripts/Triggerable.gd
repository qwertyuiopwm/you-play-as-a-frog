extends Node2D

export var State = false


func trigger(trigger: bool):
	onTriggerAny(trigger)
	if State == trigger: return
	
	onTrigger(trigger)


func onTriggerAny(_trigger: bool):
	pass

func onTrigger(_trigger: bool):
	pass
