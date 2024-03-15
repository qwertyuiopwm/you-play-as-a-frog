extends "res://Scripts/FreeOnTrigger.gd"


var pickupable = false setget pickupable_set, pickupable_get

func pickupable_set(val):
	pickupable = val
	$PlayerDetector.Enabled = false
	
func pickupable_get():
	return pickupable
