extends "res://Scripts/Enemy.gd"


var state


enum states {
	DEFAULT,
	CIRCLE,
	SWOOP,
	SWOOPING,
}


func _physics_process(delta):
	set_target()
	state = get_state()
	
	match state:
		states.DEFAULT:
			pass


func animation_finished():
	pass


func get_state():
	if target == null:
		return states.DEFAULT
	
	if state == states.SWOOPING:
		return states.SWOOPING
