extends "res://Scripts/Spell.gd"

var condiment_residue = preload("res://Spells/Spell Extras/CondimentResidue.tscn")


func on_settle():
	var residue = condiment_residue.instance()
	residue.global_position = global_position
