extends "res://Scripts/Triggerable.gd"


export(PackedScene) var PACKED_SCENE
export(NodePath) onready var Scene = get_node(Scene)


func onTriggerAny(_trigger):
	var new_room = PACKED_SCENE.instance()
	
	call_deferred("add_to_tree", new_room)


func add_to_tree(new_room):
	print("adding to tree")
	get_parent().add_child(new_room)
	new_room.global_position = Scene.global_position
	
	Scene.queue_free()
	Scene = new_room
	print("done")


#func _process(_delta):
#	print(Scene.global_position)
