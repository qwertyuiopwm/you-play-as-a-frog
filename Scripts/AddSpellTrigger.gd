extends "res://Scripts/Triggerable.gd"


export var Spell:String

onready var PlayerNode = get_node("/root/Main/Player")

func onTriggerAny(_trigger):
	PlayerNode.AddSpell(Spell)
