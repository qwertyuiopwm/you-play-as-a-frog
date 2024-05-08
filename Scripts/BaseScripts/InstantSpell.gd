extends "res://Scripts/BaseScripts/Spell.gd"


var caster


func try_cast(_caster):
	caster = _caster
	if _caster.mana < MANA_COST:
		queue_free()
		return
		
	_caster.mana -= MANA_COST
	_caster.get_parent().call_deferred("add_child", self)

func _ready():
	global_position = caster.global_position
	on_cast(caster)


func on_cast(_caster):
	pass
