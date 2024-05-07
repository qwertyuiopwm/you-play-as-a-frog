extends "res://Scripts/BaseScripts/InstantSpell.gd"


func on_cast(_caster):
	var _c = $AnimatedSprite.connect("frame_changed", self, "shake_if_time")
	var __c = $AnimatedSprite.connect("animation_finished", self, "queue_free")
	var ___c = $AnimatedSprite.play("default")


func shake_if_time():
	if not $AnimatedSprite.frame == 4:
		return
	
	$BreakTiles.break_tiles()
