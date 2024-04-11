extends RigidBody2D


export var DAMAGE = 10
export var COOLDOWN = 1
export var MANA_COST = 15
export var CAN_SELF_CAST = false
export var SpellIcon: String
export(Array, PackedScene) var BlockedEffects
export(Array, PackedScene) var BlockedImmunities
export(Array, PackedScene) var BlockedTargets


onready var Main = get_node("/root/Main")
onready var Player = get_parent().get_node("Player")

# 2 to the power of layer - 1
var EnemyCollision = int(pow(2,8))
var WallCollision = int(pow(2,3))


func hurt(body, dmg):
	body.hurt(dmg * Player.damage_mult)


func wait(seconds):
	yield(get_tree().create_timer(seconds), "timeout")


func try_cast(_caster):
	assert(false, "OVERRIDE METHOD 'try_cast' ON %s" % self)


func try_self_cast(_caster):
	pass
