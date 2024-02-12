extends Node2D


export var Triggerables: Array
export var StartOn = false
export var CanOn = true
export var CanOff = false
var prev_triggered = StartOn

func get_enemies_left():
	return get_child_count()

func delete_all_enemies():
	for enemy in get_children():
		enemy.queue_free()


func trigger(_trigger: bool):
	for triggerable in Triggerables:
		triggerable.trigger(_trigger)


func condition():
	return get_enemies_left() > 0


func _process(_delta):
	var triggered = condition()
	
	if triggered and CanOn and (prev_triggered == false):
		prev_triggered = true
		trigger(true)
	
	if (not triggered) and CanOff and (prev_triggered == true):
		prev_triggered = false
		trigger(false)
