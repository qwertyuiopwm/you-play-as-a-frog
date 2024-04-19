extends "res://Scripts/BaseScripts/Triggerable.gd"


export(Array, NodePath) var Triggerables
export var Delay: float = 0
export var InvertSignal := false


func onTriggerAny(trigger):
	if Delay > 0:
		yield(Main.wait(Delay), "completed")
	for _triggerable in Triggerables:
		var triggerable = get_node(_triggerable)
		triggerable.trigger((!trigger) if InvertSignal else trigger)
