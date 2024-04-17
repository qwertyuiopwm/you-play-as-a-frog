extends "res://Scripts/Triggerable.gd"


export(Array, NodePath) var Triggerables
export var delay: float = 0


func onTriggerAny(trigger):
	if delay > 0:
		yield(Main.wait(delay), "completed")
	for _triggerable in Triggerables:
		var triggerable = get_node(_triggerable)
		triggerable.trigger(trigger)
