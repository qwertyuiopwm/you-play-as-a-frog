extends "res://Scripts/BaseScripts/Triggerable.gd"

onready var SaveSys = Main.get_node("Save")

func onTriggerAny(_trigger):
	SaveSys.save()
