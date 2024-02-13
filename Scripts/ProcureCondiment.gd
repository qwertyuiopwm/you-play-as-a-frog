extends "res://Scripts/Spell.gd"


var condiment_residue = preload("res://Spells/Spell Extras/CondimentResidue.tscn")


func _on_Area2D_body_entered(body):
	hit(body)


func on_settle():
	var residue = condiment_residue.instance()
	residue.global_position = global_position
