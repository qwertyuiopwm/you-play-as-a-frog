extends Node2D


export var Triggerables: Array
export var Enabled = true
export var TriggerVal = false
export var DeleteOnTrigger = true

onready var Main = get_node("/root/Main")
onready var Player = Main.get_node("Player")


func trigger(_trigger: bool):
	for triggerable_path in Triggerables:
		var triggerable = get_node(triggerable_path)
		triggerable.trigger(_trigger)


func condition():
	pass


func _process(_delta):
	if not Enabled:
		return
	if !condition():
		return
	trigger(TriggerVal)
	if DeleteOnTrigger:
		queue_free()
