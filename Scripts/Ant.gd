extends "res://Scripts/Enemy.gd"


export var CIRCLE_RADIUS = 100


enum states {
	STILL,
	CIRCLE,
	SWARM,
	BITE,
	BITING,
}


var state
var randomnum = randf()


func _physics_process(delta):
	set_target()
	state = get_state()
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
		states.CIRCLE:
			target_pos = get_circle_position(randomnum, CIRCLE_RADIUS)


func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.BITING:
		return states.BITING
	
	if (global_position.distance_to(target_pos) <= ATTACK_RANGE):
		return states.BITE

	if (global_position.distance_to(target_pos) <= TARGET_RANGE):
		return states.SWARM


func animation_finished():
	match $AnimatedSprite.animation:
		"bite":
			pass
