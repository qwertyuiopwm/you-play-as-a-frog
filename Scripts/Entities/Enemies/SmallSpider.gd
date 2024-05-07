extends "res://Scripts/BaseScripts/Enemy.gd"


export var CIRCLE_RADIUS = 60
export var ATTACK_RADIUS = 70
export var CONTACT_DAMAGE = 10
export var JUMP_ROTATION_SPEED = 400
export var JUMP_DIST = 200
export var TARGET_COMFORT_RADIUS = 10
export var DIR_ROT_OFFSET = 30


enum states {
	STILL,
	CHASE,
	JUMP,
	JUMPING,
}


var state = states.STILL
var rng = RandomNumberGenerator.new()
var randnum = 0


func _ready():
	var _c = $HitCollider.connect("body_entered", self, "HitCollider_body_entered")

func on_death():
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")

func _physics_process(delta):
	set_target()
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
	
	
	match state:
		states.STILL: 
			$AnimatedSprite.play("still")
			randnum = rng.randi_range(90-DIR_ROT_OFFSET, 90+DIR_ROT_OFFSET)
			
		states.CHASE:
			$AnimatedSprite.play("walk")
			rotation = 0
			
			if global_position.distance_to(target_player.global_position) < ATTACK_RADIUS:
				state = states.JUMP
			
			var player_pos = target_player.global_position
			var dir_player = global_position.direction_to(player_pos)
			var target_offset_dir = dir_player.rotated(deg2rad(randnum))
			
			target_pos = player_pos + target_offset_dir * CIRCLE_RADIUS
			move(target_pos, delta)
			
			
		states.JUMP:
			$AnimatedSprite.play("still")
			var dir_player = global_position.direction_to(target_player.global_position)
			target_pos = global_position + dir_player * JUMP_DIST
			state = states.JUMPING
			
		states.JUMPING:
			rotation_degrees += JUMP_ROTATION_SPEED * delta
			var vel: Vector2 = move(target_pos, delta)
			if vel.length() < 10:
				state = states.STILL


func get_state():
	if state == states.JUMPING:
		return states.JUMPING
	
	if target_player == null:
		return states.STILL
	
	if state == states.STILL:
		return states.CHASE
	
	return state


func HitCollider_body_entered(body):
	if state != states.JUMPING:
		return
	if not body.is_in_group("Player"):
		return
	
	body.hurt(CONTACT_DAMAGE)
