extends "res://Scripts/Trigger.gd"


export var TriggerOnEnter = true
export var TriggerOnExit = false
export var FreeOnTrigger = true
export var InverseSignal = false


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") and TriggerOnEnter:
		trigger(!InverseSignal)
		if FreeOnTrigger: queue_free()


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player") and TriggerOnExit:
		trigger(InverseSignal)
		if FreeOnTrigger: queue_free()
