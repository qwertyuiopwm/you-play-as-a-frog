extends "res://Scripts/BaseScripts/Enemy.gd"


signal enabled

export var Enabled: bool = false setget setEnabled

func setEnabled(val):
	Enabled = val
	
	yield(on_enabled(), "completed")
	
	if val:
		emit_signal("enabled")

func on_enabled():
	pass
