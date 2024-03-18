extends "res://Scripts/Triggerable.gd"


export(Array, PackedScene) var Enemies

onready var main = get_node("/root/Main")


func onTriggerAny(trigger):
	for enemy in Enemies:
		enemy.instance()
		
		main.call_deferred("add_child", enemy)
