extends Node


export var PopupName: String
export var Visible: bool

onready var PlayerNode = get_node("/root/Main/Player")
onready var GUI = PlayerNode.get_node("GUI")

func trigger(_trigger):
	GUI.get_node("Popups").get_node(PopupName).visible = Visible
