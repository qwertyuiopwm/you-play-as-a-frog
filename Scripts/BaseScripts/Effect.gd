extends Node2D


enum stackBehaviour {
	DONT_OVERRIDE,
	OVERRIDE,
	STACK,
}


export var duration := 5.0
export(int) var MAX_STACKS = 0
export(stackBehaviour) var StackTimeBehaviour = stackBehaviour.DONT_OVERRIDE
export(stackBehaviour) var StackStacksBehaviour = stackBehaviour.DONT_OVERRIDE
export var Permanent = false

var stacks: int = 0

func affect(entity, delta):
	duration -= delta * int(not Permanent)
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()
		return
	on_affect(entity, delta)


func stack(_duration, _stacks):
	stacks = int(min(stacks + 1, MAX_STACKS))
	
	match StackStacksBehaviour:
		stackBehaviour.OVERRIDE_TIME:
			duration = _duration
		stackBehaviour.STACK_TIME:
			duration += _duration
	
	match StackTimeBehaviour:
		stackBehaviour.OVERRIDE_TIME:
			stacks = _stacks
		stackBehaviour.STACK_TIME:
			stacks += _stacks
	
	on_stack()


func on_stack():
	pass

func on_affect(_entity, _delta):
	pass

func on_effect_removed(_entity):
	pass
