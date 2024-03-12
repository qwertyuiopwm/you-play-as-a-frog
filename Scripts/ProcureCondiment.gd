extends "res://Scripts/BouncingSpell.gd"


export var SLIPPY_DURATION = 2


var condiment_residue = preload("res://Spells/Spell Extras/CondimentResidue.tscn")


func on_settle(body):
	if body is Entity:
		body.Afflict(Effects.slippy, SLIPPY_DURATION)
		return
	
	if not body is TileMap: return
	
	var residue = condiment_residue.instance()
	get_parent().add_child(residue)
	residue.global_position = global_position


func animation_finished():
	match $AnimatedSprite.animation:
		"start":
			$AnimatedSprite.play("default")


func on_start():
	var _obj = $AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.play("start")
