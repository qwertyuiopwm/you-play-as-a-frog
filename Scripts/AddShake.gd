extends "res://Scripts/FreeOnTrigger.gd"


var Pickupable = false setget pickupable_set, pickupable_get

func pickupable_set(val):
	Pickupable = val
	$PlayerDetector.Enabled = false
	
func pickupable_get():
	return Pickupable
