extends Node2D


enum stackBehaviour {
	DONT_OVERRIDE_TIME,
	OVERRIDE_TIME,
	STACK_TIME,
}


export var duration := 5.0
export(int) var MAX_STACKS = 0
export(stackBehaviour) var StackBehaviour = stackBehaviour.DONT_OVERRIDE_TIME
export var Permanent = false

var stacks: int = 0

func affect(entity, delta):
	duration -= delta * int(not Permanent)
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()
		return
	on_affect(entity, delta)


func stack(_duration):
	stacks = int(min(stacks + 1, MAX_STACKS))
	match StackBehaviour:
		stackBehaviour.OVERRIDE_TIME:
			duration = _duration
		stackBehaviour.STACK_TIME:
			duration += _duration
	on_stack()


func on_stack():
	pass

func on_affect(_entity, _delta):
	pass

func on_effect_removed(_entity):
	pass
