extends "res://Scripts/Triggerable.gd"


onready var Player = Main.get_node("Player")

func onTriggerAny(_trigger):
	Player.get_node("GUI").hide()
