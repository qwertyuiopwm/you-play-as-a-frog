extends "res://Scripts/Triggerable.gd"


export var Spell:String

onready var PlayerNode = get_node("/root/Main/Player")

func onTriggerAny(_trigger):
	if not Spells.AllSpells.has(Spell):
		return
	PlayerNode.PlayerSpells.push_back(Spells.AllSpells[Spell])
