extends "res://Scripts/Enemy.gd"


export var NUM_SEGMENTS = 3

var segment_scene = preload("res://Enemies/CentipedeSegment.tscn")


func _ready():
	var next_segment = self
	for x in NUM_SEGMENTS:
		var segment = segment_scene.instance()
		
		segment.next_segment = next_segment
		get_parent().call_deferred("add_child", segment)
		
		next_segment = segment


func _physics_process(_delta):
	var players = get_tree().get_nodes_in_group("Player")
	
	#if not players: return
	var target = players[0]
	
	rotation = global_position.angle_to_point(target.global_position)
	
	var target_pos = target.global_position
	var velocity = global_position.direction_to(target_pos) * SPEED
	var _ret = move_and_slide(velocity)
