extends Entity


onready var next_segment_back = next_segment.get_node("Back")

var next_segment
var head


func _ready():
	$AnimatedSprite.playing = true
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)


func _physics_process(_delta):
	rotation = global_position.angle_to_point(next_segment_back.global_position)
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)


func hurt(damage: float):
	head.hurt(damage)


func Afflict(effect, duration: float = -1, override_immunities := false):
	if has_effect(effect) and not next_segment.has_effect(effect):
		next_segment.Afflict(effect, duration, override_immunities)
		return
		
	.Afflict(effect, duration, override_immunities)
