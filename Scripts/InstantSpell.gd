extends "res://Scripts/Spell.gd"


func try_cast(caster):
	if caster.mana >= MANA_COST:
		on_cast(caster)
	
	queue_free()


func on_cast(caster):
	pass
