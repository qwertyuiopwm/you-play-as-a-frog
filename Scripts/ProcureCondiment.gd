extends "res://Scripts/BouncingSpell.gd"

var condiment_residue = preload("res://Spells/Spell Extras/CondimentResidue.tscn")


func on_settle():
	var residue = condiment_residue.instance()
	get_parent().add_child(residue)
	residue.global_position = global_position
	print(residue)
	


func animation_finished():
	match $AnimatedSprite.animation:
		"start":
			$AnimatedSprite.play("default")


func on_start():
	$AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.play("start")
