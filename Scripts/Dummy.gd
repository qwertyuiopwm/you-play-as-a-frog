extends "res://Scripts/Enemy.gd"


func _process(delta):
	health = maxHealth


func hurt(damage):
	$AnimatedSprite.play("default")
