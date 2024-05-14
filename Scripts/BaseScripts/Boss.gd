extends "res://Scripts/BaseScripts/Enemy.gd"


signal enabled

export var Enabled: bool = false setget setEnabled

func setEnabled(val):
	Enabled = val
	
	on_enabled()
	
	if val:
		emit_signal("enabled")


func on_enabled():
	pass


func _process(_delta):
	if has_node("BossBar"):
		$BossBar.visible = Enabled
