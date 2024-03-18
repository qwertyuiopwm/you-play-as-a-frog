extends "res://Scripts/Triggerable.gd"


export(Array, PackedScene) var Enemies
export(NodePath) var SpawnPos
export var SpawnRadius := 0.0

onready var main = get_node("/root/Main")


func onTriggerAny(trigger):
	for enemy in Enemies:
		enemy.instance()
		
		var enemy_pos = get_node(SpawnPos.global_position)
		var pos_offset = Vector2.ZERO
		pos_offset.x = ((randf() * 2) - 1) * SpawnRadius
		pos_offset.y = ((randf() * 2) - 1) * SpawnRadius
		
		main.call_deferred("add_child", enemy)
		
		enemy.global_position = enemy_pos + pos_offset
