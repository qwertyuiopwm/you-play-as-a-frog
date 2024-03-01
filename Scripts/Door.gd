extends "res://Scripts/Triggerable.gd"

export var OpenOffset = Vector2(0, 0)
export var Hide = true


var startPos
var openPos

export var TRIGGER_ON_START = true


func _ready():
	startPos = global_position
	openPos = global_position + OpenOffset
	if not TRIGGER_ON_START: return
	trigger(State)
	


func onTriggerAny(close: bool):
	global_position = (startPos if close else openPos)
	
	if Hide:
		visible = close
