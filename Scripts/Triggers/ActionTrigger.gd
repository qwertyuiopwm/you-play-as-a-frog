extends "res://Scripts/BaseScripts/Trigger.gd"


enum actionType {
	pressed,
	released,
}

export(Array, String) var Actions
export(actionType) var ActionType = actionType.pressed
export var MaxDistance: float


var typeToMethod = {
	actionType.pressed: 'is_action_just_pressed',
	actionType.released: 'is_action_just_released',
}


func condition():
	var actionReached = false
	for action in Actions:
		if Input.call(typeToMethod[ActionType], action):
			actionReached = true
			break
	if not actionReached:
		return false
	if MaxDistance != 0 and global_position.distance_to(Player.global_position) > MaxDistance:
		return false
	return true
