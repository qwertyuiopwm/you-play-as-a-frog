extends "res://Scripts/Trigger.gd"


func condition():
	return get_child_count() == 0
