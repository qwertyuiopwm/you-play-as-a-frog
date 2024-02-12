extends "res://Scripts/Spell.gd"


func _on_ProcureCondiment_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	remaining_bounces -= 1
	print(remaining_bounces)
