extends "res://Scripts/Triggerable.gd"


onready var Player = get_node("/root/Main/Player")


func onTriggerAny(_trigger):
	Player.get_node("PlayerSprite").visible = false
	Player.get_node("BoatSprite").visible = true
	
	queue_free()
