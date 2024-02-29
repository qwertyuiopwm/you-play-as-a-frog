extends Node2D

export var State = false


func trigger(trigger: bool):
	onTriggerAny(trigger)
	if State == trigger: return
	
	onTrigger(trigger)


func onTriggerAny(trigger: bool):
	pass

func onTrigger(trigger: bool):
	pass
