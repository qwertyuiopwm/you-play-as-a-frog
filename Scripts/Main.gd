extends Node2D


export var GameStarted = false

func cast_ray(root, target, layer, ignore):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	return space_state.intersect_ray(root, target, ignore, layer)
