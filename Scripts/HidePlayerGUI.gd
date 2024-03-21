extends "res://Scripts/Triggerable.gd"


onready var Player = Main.get_node("Player")

func onTriggerAny(trigger):
	Player.get_node("GUI").hide()
