extends "res://Scripts/BaseScripts/Trigger.gd"

export var Count:int = 0
export var CountNeeded: int


func condition():
	return Count >= CountNeeded
