extends "res://Scripts/Triggerable.gd"

export var OpenOffset = Vector2(0, 0)
export var Hide = true

var startPos = global_position
var openPos = global_position + OpenOffset



func onTriggerAny(close: bool):
	global_position = (startPos if close else openPos)
	
	if Hide:
		visible = close
