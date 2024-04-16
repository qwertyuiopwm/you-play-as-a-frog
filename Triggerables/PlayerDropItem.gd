extends "res://Scripts/Triggerable.gd"


export var DropAngle: int

onready var Player = Main.get_node("Player")


func onTriggerAny(_trigger):
	Player.call_deferred("drop_big_item", DropAngle)
