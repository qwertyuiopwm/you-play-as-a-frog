extends Node2D

export var State = false
onready var Main = get_node("/root/Main")


func trigger(trigger: bool):
	onTriggerAny(trigger)
	if State == trigger: return
	
	onTrigger(trigger)


func onTriggerAny(_trigger: bool):
	pass

func onTrigger(_trigger: bool):
	pass
