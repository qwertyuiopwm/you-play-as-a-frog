extends "res://Scripts/Triggerable.gd"


export(float) var SlideTime
export(NodePath) onready var TargetPos = get_node(TargetPos)

onready var Player = get_node("/root/Main/Player")


func _ready():
	var _c = $Tween.connect("tween_completed", self, "tween_complete")


func onTriggerAny(_trigger):
	Player.can_move = false
	$Tween.interpolate_property(Player, "position", 
		Player.global_position, 
		TargetPos.global_position, 
		SlideTime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()


func tween_complete():
	Player.can_move = true
