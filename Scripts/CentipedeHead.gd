extends "res://Scripts/Enemy.gd"


export var CONTACT_DAMAGE = 20
export var NUM_SEGMENTS = 3

var segment_scene = preload("res://Enemies/Centipede/CentipedeSegment.tscn")
var tail_scene = preload("res://Enemies/Centipede/CentipedeTail.tscn")

var segments = []

func _ready():
	var next_segment = self
	for x in NUM_SEGMENTS:
		var segment = segment_scene.instance()
		segments.push_back(segment)
		segment.next_segment = next_segment
		
		next_segment = segment
	
	var tail = tail_scene.instance()
	segments.push_back(tail)
	tail.next_segment = next_segment
	
	for segment in segments:
		segment.head = self
		get_parent().call_deferred("add_child", segment)
		segment.get_node("HitCollider").connect("body_entered", self, "_body_entered")


func _physics_process(delta):
	var players = get_tree().get_nodes_in_group("Player")
	
	#if not players: return
	var target = players[0]
	
	
	var target_pos = target.global_position
	move(target_pos, delta)


func _body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(CONTACT_DAMAGE)
