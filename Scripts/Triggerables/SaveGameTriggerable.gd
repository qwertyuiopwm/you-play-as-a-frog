extends "res://Scripts/BaseScripts/Triggerable.gd"

onready var SaveSys = Main.get_node("Save")
onready var Player = Main.get_node("Player")
onready var GUI = Player.get_node("GUI")
onready var SavingPopup = GUI.get_node("Saving")

func onTriggerAny(_trigger):
	SavingPopup.visible = true
	yield(Main.wait(0.1), "completed")
	SaveSys.save()
	yield(SaveSys, "SaveFinished")
	SavingPopup.visible = false
