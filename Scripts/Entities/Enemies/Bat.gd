extends "res://Scripts/BaseScripts/Enemy.gd"


export var ATTACHED_DAMAGE_PER_SECOND = 50
export var RUSHING_SPEED = 200
export var RUSH_RANGE = 150

enum states {
	STILL,
	MOVING,
	RUSHING,
	ATTACHED,
	REMOVED,
}

var state = states.STILL
onready var sprite = $AnimatedSprite

func _ready():
	sprite.play("Default")
	var _obj = $HitCollider.connect("body_entered", self, "_on_hit")
	var _obj2 = sprite.connect("animation_finished", self, "_on_animation_finished")
	
func _physics_process(delta):
	set_target()
	if target_player != null:
		target_pos = target_player.global_position
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
	
	match state:
		states.STILL:
			curr_speed = SPEED
		states.ATTACHED:
			if target_player.dashing:
				state = states.REMOVED
				sprite.play("Removed")
				return
			position = target_pos - Vector2(0, 20)
			target_player.hurt(ATTACHED_DAMAGE_PER_SECOND * delta)
		states.MOVING:
			curr_speed = SPEED
			sprite.play("Default")
			move(target_pos, delta)
		states.RUSHING:
			curr_speed = RUSHING_SPEED
			sprite.play("Rushing")
			move(target_pos, delta)
		states.REMOVED:
			curr_speed = 0

func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.ATTACHED:
		return states.ATTACHED
	
	if state == states.REMOVED:
		return states.REMOVED
		
	if (global_position.distance_to(target_pos) <= RUSH_RANGE):
		return states.RUSHING

	if (global_position.distance_to(target_pos) <= TARGET_RANGE):
		return states.MOVING

func _on_hit(body):
	if not body.is_in_group("Player"):
		return
	state = states.ATTACHED
	sprite.play("Attached")

func _on_animation_finished():
	match sprite.animation:
		"Removed":
			sprite.play("Default")
			state = states.STILL
