extends "res://Scripts/Triggerables/FreeOnTrigger.gd"


var Pickupable = false setget pickupable_set, pickupable_get

func pickupable_set(val):
	Pickupable = val
	$PlayerDetector/CollisionShape2D.disabled = !val
	
func pickupable_get():
	return Pickupable
