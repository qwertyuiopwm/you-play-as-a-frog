extends "res://Scripts/BaseScripts/BouncingSpell.gd"


export var POISON_DURATION = 2

func on_settle(body):
	$AnimatedSprite.play("hit")
	
	yield($AnimatedSprite, "animation_finished")
	emit_signal("settled")
	
	if body is Entity:
		body.Afflict(Effects.poison, POISON_DURATION)
		return


func animation_finished():
	match $AnimatedSprite.animation:
		"start":
			$AnimatedSprite.play("default")


func on_start():
	var _obj = $AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.play("start")


func try_self_cast(player):
	pass
