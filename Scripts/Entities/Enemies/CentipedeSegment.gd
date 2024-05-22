extends Entity


var next_segment_back

var next_segment
var head


func _ready():
	if not is_instance_valid(next_segment):
		queue_free()
		return
	next_segment_back = next_segment.get_node("Back")
	var _c = $AnimatedSprite.connect("animation_finished", self, "animation_finished")
	$AnimatedSprite.playing = true
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)


func _physics_process(_delta):
	if not is_instance_valid(next_segment_back):
		queue_free()
		return
	if $AnimatedSprite.animation == "death":
		return
	rotation = global_position.angle_to_point(next_segment_back.global_position)
	global_position = next_segment_back.global_position - $Front.position.rotated(rotation)


func hurt(damage: float, ignore_hit_delay=false):
	head.hurt(damage, ignore_hit_delay)


func Afflict(effect, duration: float=-1, stacks=1, override_immunities:=false):
	if has_effect(effect) and not next_segment.has_effect(effect):
		next_segment.Afflict(effect, duration, stacks, override_immunities)
		return
		
	.Afflict(effect, duration, override_immunities)


func animation_finished():
	if $AnimatedSprite.animation == "death":
		queue_free()
