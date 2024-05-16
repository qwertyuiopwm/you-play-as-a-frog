extends "res://Scripts/BaseScripts/Triggerable.gd"


export(Array, String) var SpellsToAdd = []
export(Array, String) var SpellsToRemove = []

onready var PlayerNode = get_node("/root/Main/Player")

func onTriggerAny(_trigger):
	for spell in SpellsToRemove:
		PlayerNode.RemoveSpell(spell)
	
	for spell in SpellsToAdd:
		PlayerNode.AddSpell(spell)
