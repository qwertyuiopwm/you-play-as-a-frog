extends "res://Scripts/BaseScripts/Triggerable.gd"


var TARGET_COMFORT_RANGE = 5

export var OpenOffset = Vector2(0, 0)
export var Hide = true
export var OPEN_TIME = 0

onready var moveTween: Tween = Tween.new()
onready var start_pos = position

var closed:bool


func _ready():
	Main.call_deferred("add_child", moveTween)
	call_deferred("setup")


func setup():
	trigger(State)


func onTriggerAny(close: bool):
	closed = close
	if Hide:
		visible = close
	
	var target_pos = start_pos if closed else start_pos + OpenOffset
	
	var _v = moveTween.interpolate_property(self, "position", 
		position, 
		target_pos, 
		OPEN_TIME, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	var __v = moveTween.start()
