extends "res://Scripts/Triggerable.gd"


export var Inverse = false

onready var Player = get_node("/root/Main/Player")


func onTriggerAny(_trigger):
	Player.get_node("PlayerSprite").visible = Inverse
	Player.get_node("BoatSprite").visible = !Inverse
	
	queue_free()
