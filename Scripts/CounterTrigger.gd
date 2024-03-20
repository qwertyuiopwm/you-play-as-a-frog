extends "res://Scripts/Trigger.gd"

export var Count:int = 0
export var CountNeeded: int


func condition():
	return Count >= CountNeeded
