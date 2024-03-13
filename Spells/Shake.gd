extends Node2D


export var radius = 25


func _ready():
	print($Area2D/CollisionShape2D.shape.radius)
	on_cast()


func on_cast():
	print("printing colliding bodies...")
	print($Area2D.get_overlapping_bodies())
	print("printing colliding areas...")
	print($Area2D.get_overlapping_areas())
