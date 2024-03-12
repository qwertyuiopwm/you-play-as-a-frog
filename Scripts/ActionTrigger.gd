extends "res://Scripts/Trigger.gd"


export(Array, String) var Actions
export var MaxDistance:float

func condition():
	var actionReached = false
	for action in Actions:
		if Input.is_action_just_pressed(action):
			actionReached = true
			break
	if not actionReached:
		return false
	if MaxDistance != 0 and global_position.distance_to(Player.global_position) > MaxDistance:
		return false
	return true
