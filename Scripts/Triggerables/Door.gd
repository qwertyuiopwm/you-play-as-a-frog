extends "res://Scripts/BaseScripts/Triggerable.gd"


export var TRIGGER_ON_START = true

var TARGET_COMFORT_RANGE = 5

export var OpenOffset = Vector2(0, 0)
export var Hide = true
export var OpenSpeed = -1

var start_pos
var open_pos
var closed:bool


func _ready():
	call_deferred("setup")


func setup():
	start_pos = global_position
	open_pos = global_position + OpenOffset
	if not TRIGGER_ON_START: return
	trigger(State)


func _process(delta):
	var target_pos = start_pos if closed else open_pos
	
	var dist_to = global_position.distance_to(target_pos)
	if (OpenSpeed <= 0) or (0 < dist_to and dist_to < TARGET_COMFORT_RANGE):
		global_position = target_pos
		return
	
	if dist_to < TARGET_COMFORT_RANGE: return
	
	var dir_to = global_position.direction_to(target_pos)
	global_position += dir_to * OpenSpeed * delta


func onTriggerAny(close: bool):
	closed = close
	if Hide:
		visible = close
