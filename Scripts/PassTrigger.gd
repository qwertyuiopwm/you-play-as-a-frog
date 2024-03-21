extends "res://Scripts/Triggerable.gd"


export(Array, NodePath) var Triggerables


func onTriggerAny(trigger):
	for _triggerable in Triggerables:
		var triggerable = get_node(_triggerable)
		triggerable.trigger(trigger)
