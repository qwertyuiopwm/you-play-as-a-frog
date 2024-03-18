extends "res://Scripts/Triggerable.gd"


export(Array, PackedScene) var Enemies
export(NodePath) var EnemyManager
export(NodePath) var SpawnPos
export var SpawnRadius := 0.0


func onTriggerAny(trigger):
	for enemy in Enemies:
		enemy.instance()
		
		var enemy_pos = get_node(SpawnPos.global_position)
		var pos_offset = Vector2.ZERO
		if SpawnRadius > 0:
			pos_offset.x = ((randf() * 2) - 1) * SpawnRadius
			pos_offset.y = ((randf() * 2) - 1) * SpawnRadius
		
		get_node(EnemyManager).call_deferred("add_child", enemy)
		
		enemy.global_position = enemy_pos + pos_offset
