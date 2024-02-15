extends Node2D


export var Triggerables: Array
export var TriggerVal = false


func trigger(_trigger: bool):
	for triggerable_path in Triggerables:
		var triggerable = get_node(triggerable_path)
		triggerable.trigger(_trigger)


func condition():
	return get_child_count() == 0


func _process(_delta):
	if condition():
		trigger(TriggerVal)
		queue_free()
