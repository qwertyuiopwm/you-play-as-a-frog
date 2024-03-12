extends "res://Scripts/Triggerable.gd"


export var PopupName: String
export var Inverted: bool

onready var PlayerNode = get_node("/root/Main/Player")
onready var GUI = PlayerNode.get_node("GUI")

func onTriggerAny(trigger):
	if Inverted:
		trigger = not trigger
	GUI.get_node("Popups").get_node(PopupName).visible = trigger
