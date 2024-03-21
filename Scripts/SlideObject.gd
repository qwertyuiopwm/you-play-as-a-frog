extends "res://Scripts/Triggerable.gd"


export(NodePath) onready var ObjectToSlide = get_node(ObjectToSlide)
export(float) var SlideTime
export(NodePath) var TargetPos

onready var Player = get_node("/root/Main/Player")


func _ready():
	$Tween.connect("tween_completed", self, "tween_done")


func onTriggerAny(trigger):
	ObjectToSlide.can_move = false
	$Tween.interpolate_property(ObjectToSlide, "position", 
		global_position, 
		TargetPos.global_position, 
		SlideTime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()


func tween_completed():
	if ObjectToSlide == Player:
		ObjectToSlide.can_move = true
