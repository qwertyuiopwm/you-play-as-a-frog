extends "res://Scripts/BaseScripts/BouncingSpell.gd"


export(float) var SLIPPY_DURATION = 2
export(float) var SELF_SLIPPY_DURATION = 1.5
export var SETTLE_SOUND := ""
export var SLIP_SOUND := ""


var condiment_residue = preload("res://Spells/Spell Extras/CondimentResidue.tscn")


func on_settle(body):
	if body is Entity:
		body.Afflict(Effects.slippy, SLIPPY_DURATION)
<<<<<<< HEAD:Scripts/ProcureCondiment.gd
		Player.MusicPlayer.PlayOnNode(SLIP_SOUND, Player)
		return
=======
		emit_signal("settled")
		return false
>>>>>>> 0ac80e42295ab507043cf95343afad113e369356:Scripts/Spells/ProcureCondiment.gd
	
	if not body is TileMap: 
		emit_signal("settled")
		return false
	
<<<<<<< HEAD:Scripts/ProcureCondiment.gd
	Player.MusicPlayer.PlayOnNode(SETTLE_SOUND, Player)
	
=======
	emit_signal("settled")
>>>>>>> 0ac80e42295ab507043cf95343afad113e369356:Scripts/Spells/ProcureCondiment.gd
	var residue = condiment_residue.instance()
	get_parent().call_deferred("add_child", residue)
	residue.global_position = global_position
	return false


func animation_finished():
	match $AnimatedSprite.animation:
		"start":
			$AnimatedSprite.play("default")


func on_start():
	var _obj = $AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.play("start")


func try_self_cast(player):
	if player.mana < MANA_COST: 
		queue_free()
		return
	
	player.mana -= MANA_COST
	player.Afflict(Effects.slippy, SELF_SLIPPY_DURATION)
