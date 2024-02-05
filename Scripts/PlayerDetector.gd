extends Area2D


export var Triggerables: Array
export var CanOn = true
export var CanOff = false
export var Reusable = false
export var InverseSignal = false


func trigger(_trigger: bool):
	for triggerable in Triggerables:
		get_node(triggerable).trigger(_trigger)


func _ready():
	print("e")


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") and CanOn:
		trigger(!InverseSignal)
		if !Reusable: queue_free()


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player") and CanOff:
		trigger(InverseSignal)
		if !Reusable: queue_free()
