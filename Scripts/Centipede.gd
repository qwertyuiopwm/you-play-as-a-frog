extends KinematicBody2D


onready var next_segment_back = next_segment.get_node("Back")

var next_segment
var head


func hurt(damage: float):
	head.hurt(damage)


func _ready():
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)


func _physics_process(_delta):
	rotation = global_position.angle_to_point(next_segment_back.global_position)
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)
