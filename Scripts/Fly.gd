extends "res://Scripts/Enemy.gd"


export var CIRCLE_RADIUS = 50
export var SWOOP_SPEED = 150

var TARGET_COMFORT_RADIUS = 20


var randomnum = randf()
var state


enum states {
	DEFAULT,
	CIRCLE,
	SWOOP,
	SWOOPING,
}


func _ready():
	$fly_vis.visible = debug


func _process(delta):
	set_target()
	state = get_state()


func _physics_process(delta):
	STEERING_MULT = 5
	
	if target_pos: $fly_vis.global_position = target_pos
	if state == states.SWOOPING: modulate = Color(1, .9, .9)
	else: modulate = Color(1, 1, 1)
	
	match state:
		states.DEFAULT:
			var target_offset = randf() / 10 + .05
			if randf() >= .5:
				target_offset = -target_offset
				
			randomnum += target_offset
			
		
		states.CIRCLE:
			curr_speed = SPEED
			target_pos = get_circle_position(randomnum, CIRCLE_RADIUS)
			move(target_pos, delta)
		
		states.SWOOP:
			randomnum = fmod((randomnum + .5), 1)
			state = states.SWOOPING
		
		states.SWOOPING:
			curr_speed = SWOOP_SPEED
			target_pos = get_circle_position(randomnum, CIRCLE_RADIUS)
			move(target_pos, delta)


func animation_finished():
	pass


func get_state():
	if target_player == null or target_pos == null:
		return states.DEFAULT
	
	if state == states.SWOOPING:
		if global_position.distance_to(target_pos) < 1:
			return states.DEFAULT
		return states.SWOOPING
	
	if state == states.CIRCLE and global_position.distance_to(target_pos) < 3:
		return states.SWOOP
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.CIRCLE
	
	
