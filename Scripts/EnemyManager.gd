extends "res://Scripts/Trigger.gd"


var waiting_until_enemy = false


func _ready():
	if len(get_children()) <= 0:
		waiting_until_enemy = true


func _process(_delta):
	if waiting_until_enemy and len(get_children()) > 0:
		waiting_until_enemy = false


func condition():
	var cond = (len(get_children()) <= 0) \
		   and (not waiting_until_enemy)
	if cond:
		print(cond)
		print(get_children())
	return cond
