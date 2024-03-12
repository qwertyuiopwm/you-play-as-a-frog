extends "res://Scripts/Enemy.gd"


var next_segment

onready var next_segment_back = next_segment.get_node("Back")


func _physics_process(_delta):
	
	rotation = global_position.angle_to_point(next_segment_back.global_position)
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)
