extends "res://Scripts/BaseScripts/InstantSpell.gd"


export var FRAME_TO_BREAK: int = 3


func on_cast(_caster):
	var _c = $AnimatedSprite.connect("frame_changed", self, "shake_if_time")
	var __c = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	var ___c = $AnimatedSprite.play("default")


func shake_if_time():
	if not $AnimatedSprite.frame == FRAME_TO_BREAK:
		return
	
	$BreakTiles.break_tiles()
