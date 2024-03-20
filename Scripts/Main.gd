extends Node2D


export var Paused = true

func wait(seconds):
	yield(get_tree().create_timer(seconds), "timeout")
	
func get_all_children(node, children=[]):
	children.push_back(node)
	for child in children:
		children = get_all_children(child, children)
	return children
	
func pause(paused:bool, exclude:Array):
	Paused = paused
	for node in get_children():
		if exclude.has(node):
			continue
		node.get_tree().paused = paused

func cast_ray(root, target, layer, ignore):
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	return space_state.intersect_ray(root, target, ignore, layer)

func cast_ray_towards_point(root, point, distance, layer, ignore):
	var targetPos = root + (root.direction_to(point)*distance)
	
	return cast_ray(root, targetPos, layer, ignore)
