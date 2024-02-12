extends RigidBody2D


export var VELOCITY = 50
export var DURATION = 5
export var BOUNCES = 0

var remaining_duration = DURATION
var remaining_bounces = BOUNCES


func _ready():
	var mouse_pos = get_global_mouse_position()
	var dir = global_position.direction_to(mouse_pos)
	linear_velocity = dir * VELOCITY


func _process(delta):
	remaining_duration -= delta
	if remaining_duration <= 0:
		free()



