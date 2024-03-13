extends "res://Scripts/Spell.gd"


func try_cast(caster):
	if caster.mana <= MANA_COST:
		queue_free()
	
	on_cast()


func on_cast():
	pass
