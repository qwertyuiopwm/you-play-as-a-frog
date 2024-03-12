extends "res://Scripts/Triggerable.gd"

export var Trigger: NodePath
export var Toggle: bool

func onTriggerAny(_trigger):
	get_node(Trigger).Enabled = Toggle
