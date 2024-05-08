extends "res://Scripts/BaseScripts/Triggerable.gd"


export(Array, NodePath) var Triggerables
export var CountNeeded: int = 0
export(Array, NodePath) onready var SpawnPosWhitelist = \
	pathsToNodes(SpawnPosWhitelist)

onready var Player = Main.get_node("Player")

var count = 0


func onTriggerAny(_trigger):
	if (not SpawnPosWhitelist) or Player.respawn_position in SpawnPosWhitelist:
		count += 1
	
	if count >= CountNeeded:
		for triggerable in Triggerables:
			triggerable.trigger(true)


func pathsToNodes(paths: Array):
	var nodes = []
	for path in paths:
		nodes.append(get_node(path))
	
	return nodes
