extends "res://Scripts/BaseScripts/Trigger.gd"


export var TriggerOnEnter = true
export var TriggerOnExit = false
export var InverseSignal = false


func _ready():
	var _c = connect("body_entered", self, "_on_PlayerDetector_body_entered")
	var __c = connect("body_exited", self, "_on_PlayerDetector_body_exited")


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") and TriggerOnEnter:
		trigger(!InverseSignal)


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player") and TriggerOnExit:
		trigger(InverseSignal)
