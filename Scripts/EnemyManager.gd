extends "res://Scripts/Trigger.gd"


var waiting_until_enemy


func _ready():
	if condition():
		waiting_until_enemy = true


func _process(_delta):
	if waiting_until_enemy and  get_child_count() > 0:
		waiting_until_enemy = false


func condition():
	return get_child_count() == 0 \
		   and not waiting_until_enemy
