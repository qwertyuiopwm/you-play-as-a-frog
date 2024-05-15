extends "res://Scripts/BaseScripts/Enemy.gd"


signal enabled

export var SHOW_BOSS_BAR: bool = true
export var Enabled: bool = false setget setEnabled

func setEnabled(val):
	Enabled = val
	
	if val:
		emit_signal("enabled")


func _process(_delta):
	if has_node("BossBar"):
		$BossBar.visible = Enabled and SHOW_BOSS_BAR
