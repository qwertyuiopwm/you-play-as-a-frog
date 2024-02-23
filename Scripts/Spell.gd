extends RigidBody2D


export var DAMAGE = 10
export var COOLDOWN = 1
export var MANA_COST = 15
export var SpellIcon: String

onready var Player = get_parent().get_node("Player")

func wait(seconds):
	yield(get_tree().create_timer(seconds), "timeout")
