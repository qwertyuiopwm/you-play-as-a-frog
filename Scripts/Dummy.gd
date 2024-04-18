extends "res://Scripts/Enemy.gd"


onready var Player = Main.get_node("Player")


func _ready():
	$AnimatedSprite.play("default")


func _process(_delta):
	health = maxHealth


func hurt(_damage):
	print(_damage)
	$AnimatedSprite.frame = 0
	$AnimatedSprite.flip_h = global_position.direction_to(Player.global_position).x < 0
