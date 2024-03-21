extends "res://Scripts/Triggerable.gd"


export(Array, PackedScene) var Enemies
export(NodePath) var EnemyManager
export(NodePath) var SpawnPos
export var SpawnRadius := 0.0

onready var enemy_manager = get_node(EnemyManager) if EnemyManager else Main
onready var spawn_pos = get_node(SpawnPos) if SpawnPos else self


func onTriggerAny(_trigger):
	for _enemy in Enemies:
		var enemy = _enemy.instance()
		
		var enemy_pos = spawn_pos.global_position
		var pos_offset = Vector2.ZERO
		if SpawnRadius > 0:
			pos_offset.x = ((randf() * 2) - 1) * SpawnRadius
			pos_offset.y = ((randf() * 2) - 1) * SpawnRadius
		
		enemy_manager.call_deferred("add_child", enemy)
		yield(enemy_manager, "child_entered_tree")
		
		enemy.global_position = enemy_pos + pos_offset
