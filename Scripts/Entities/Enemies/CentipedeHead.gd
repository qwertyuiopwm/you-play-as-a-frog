extends "res://Scripts/BaseScripts/Enemy.gd"


export var CONTACT_DAMAGE = 20
export var NUM_SEGMENTS = 3
export var SEG_SCALE_MULT = 1
export var SLIPPY_SEGMENTS_TO_SLIP = 5
export var ALWAYS_SEE_TARGET: bool = true
export var SCALE: float = 1

var segment_scene = preload("res://Enemies/Forest/Centipede/CentipedeSegment.tscn")
var tail_scene = preload("res://Enemies//Forest/Centipede/CentipedeTail.tscn")

var segments = []

func _ready():
	scale *= SCALE
	var next_segment = self
	for x in NUM_SEGMENTS:
		var segment = segment_scene.instance()
		segments.push_back(segment)
		segment.next_segment = next_segment
		
		next_segment = segment
	
	var tail = tail_scene.instance()
	segments.push_back(tail)
	tail.next_segment = next_segment
	
	var i = 0
	for segment in segments:
		i+=1
		segment.head = self
		segment.scale *= SCALE
		var seg_scale = pow(SEG_SCALE_MULT, i)
		segment.scale = Vector2(seg_scale, seg_scale)
		get_parent().call_deferred("add_child", segment)
		segment.get_node("HitCollider").connect("body_entered", self, "_body_entered")


func _physics_process(delta):
	var target = get_nearest_player()
	if ALWAYS_SEE_TARGET:
		target = Main.get_node("Player")
	
	var target_pos = target.global_position
	
	if get_num_slippy_segments() >= SLIPPY_SEGMENTS_TO_SLIP \
	   and not has_effect(Effects.slippy):
		Afflict(Effects.slippy, 10, true)
	
	move(target_pos, delta)


func get_slippy_segments():
	var slippy_segments = []
	for segment in segments:
		if segment.has_effect(Effects.slippy):
			slippy_segments.append(segment)
	return slippy_segments


func get_num_slippy_segments():
	return len(get_slippy_segments())


func Cure(effect):
	if effect == Effects.slippy:
		for segment in segments:
			segment.Cure(Effects.slippy)
	.Cure(effect)


func on_death():
	for segment in segments:
		segment.queue_free()


func _body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(CONTACT_DAMAGE)
