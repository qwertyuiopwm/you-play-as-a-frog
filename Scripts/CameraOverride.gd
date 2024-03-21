extends "res://Scripts/Triggerable.gd"


func onTriggerAny(_trigger):
	$Camera2D.make_current()
