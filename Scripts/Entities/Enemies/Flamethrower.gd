extends Node2D


export var DPS: int = 15
export var ROTATION_SPEED: float = .01
export var ROTATION_MULT: float = 1
export var Enabled: bool = false

onready var Player = get_node("/root/Main/Player")

var rotation_velocity = 0


func _physics_process(delta):
	
	var targ_angle = global_position.angle_to_point(Player.global_position)
	var direction = targ_angle - global_rotation
	
	# angles ):
	if direction > PI:
		direction -= 2 * PI
	if direction < -PI:
		direction += 2 * PI
	
	var desired_velocity = direction * ROTATION_SPEED
	var steering = (desired_velocity - rotation_velocity) * delta * ROTATION_MULT
	rotation_velocity += steering
	
	global_rotation += rotation_velocity
	$Node2D/FlamethrowerSprite.visible = Enabled
	
	if not Enabled:
		return
	
	for body in $Node2D/Area2D.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt(DPS * delta)
