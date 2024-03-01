extends RigidBody2D


export var DAMAGE = 10
export var COOLDOWN = 1
export var MANA_COST = 15
export var MANA_REQUIRED = 15 # Minimum amount of mana needed to cast spell
export var SpellIcon: String

onready var Player = get_parent().get_node("Player")

# 2 to the power of layer - 1
var EnemyCollision = int(pow(2,8))
var WallCollision = int(pow(2,3))

func wait(seconds):
	yield(get_tree().create_timer(seconds), "timeout")
