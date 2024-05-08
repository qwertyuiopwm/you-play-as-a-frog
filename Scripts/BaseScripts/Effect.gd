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

var stacks: int = 1

func affect(entity, delta):
	duration -= delta * int(not Permanent)
	if duration <= 0:
		on_effect_removed(entity)
		queue_free()
		return
	on_affect(entity, delta)


func stack(new_duration, new_stacks):
	if MAX_STACKS > 0:
		stacks = int(min(stacks, MAX_STACKS))
	
	match StackStacksBehaviour:
		stackBehaviour.OVERRIDE:
			duration = new_duration
		stackBehaviour.STACK:
			duration += new_duration
	
	match StackTimeBehaviour:
		stackBehaviour.OVERRIDE:
			stacks = new_stacks
		stackBehaviour.STACK:
			stacks += new_stacks
	
	on_stack()


func on_stack():
	pass

func on_affect(_entity, _delta):
	pass

func on_effect_removed(_entity):
	pass
