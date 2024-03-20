extends "res://Scripts/Triggerable.gd"

export var Counter: NodePath
export var AdditionOrSubtraction: int

func onTriggerAny(_trigger):
	get_node(Counter).Count += AdditionOrSubtraction
