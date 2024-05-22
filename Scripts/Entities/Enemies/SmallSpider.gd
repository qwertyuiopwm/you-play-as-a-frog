extends "res://Scripts/BaseScripts/Enemy.gd"


export var CIRCLE_RADIUS: int = 60
export var ATTACK_RADIUS: int = 70
export var CONTACT_DAMAGE: int = 10
export var JUMP_ROTATION_SPEED: int = 400
export var JUMP_DIST: int = 200
export var TARGET_COMFORT_RADIUS: int = 10
export var DIR_ROT_OFFSET: int = 30
export var BABY_SPAWN_DIST: int = 25
export var BABY_SPIDERS_SPAWNED: int = 0
export var BabySpiderScene: PackedScene

var rng = RandomNumberGenerator.new()
var randnum = 0

enum states {
	STILL,
	CHASE,
	JUMP,
	JUMPING,
}

var state = states.STILL


func _ready():
	var _c = $HitCollider.connect("body_entered", self, "HitCollider_body_entered")


func on_death():
	$AnimatedSprite.play("death")
	
	for _x in range(BABY_SPIDERS_SPAWNED):
		var inst = BabySpiderScene.instance()
		Main.call_deferred("add_child", inst)
		
		var x = rng.randi_range(-BABY_SPAWN_DIST, BABY_SPAWN_DIST)
		var y = rng.randi_range(-BABY_SPAWN_DIST, BABY_SPAWN_DIST)
		
		inst.global_position = global_position + Vector2(x, y)
	
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func _physics_process(delta):
	if health <= 0:
		return
	set_target()
	state = get_state()
	
	if is_sliding():
		move(target_pos, delta)
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
