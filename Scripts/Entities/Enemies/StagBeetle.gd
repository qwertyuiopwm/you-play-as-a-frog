extends "res://Scripts/BaseScripts/Enemy.gd"


export var RAM_DAMAGE = 10
export var RUSH_SPEED_MULT = 5
export var RUSH_DISTANCE_ERROR_RANGE = 10

onready var head = $head
onready var body = $body
onready var HitCollider = $HitCollider

var train_sound = "Train"

var moveToPos

enum states {
	STILL,
	WALK,
	ENRAGING,
	ENRAGED,
	STUNNED,
	RECOVERING,
}


var state = states.WALK

func on_death():
	head.visible = false
	body.play("death")
	yield(body, "animation_finished")
	emit_signal("death_finished")

func _physics_process(delta):
	if health <= 0:
		return
	set_target()
	if target_player != null:
		target_pos = target_player.global_position
	
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
		
	
	match state:
		states.STILL:
			body.play("still")
			head.play("still")
		states.WALK:
			curr_speed = SPEED
			body.speed_scale = 1
			body.play("walk_vert")
			head.play("still")
			align(delta)
		states.ENRAGING:
			moveToPos = target_pos
			var rayResult = Main.cast_ray_towards_point(global_position, target_pos, 900, 0b00000000_00000000_00000000_00001000, [])
			if rayResult.has("position"):
				moveToPos = rayResult.position
			body.play("still")
			head.play("enraging")
		states.ENRAGED:
			curr_speed = SPEED * RUSH_SPEED_MULT
			body.speed_scale = 1.5
			head.play("rushing")
			body.play("walk_horo")
			move(moveToPos, delta)

func align(delta):
	if not target_pos:
		return
		
	var yDistance = Vector2(0, global_position.y).distance_to(Vector2(0, target_pos.y))
	var xDistance = Vector2(global_position.x, 0).distance_to(Vector2(target_pos.x, 0))
	
	if yDistance <= xDistance:
		move(Vector2(global_position.x, target_pos.y), delta)
		return
		
	move(Vector2(target_pos.x, global_position.y), delta)

func flip_body(flipped):
	body.flip_h = flipped
	head.flip_h = flipped
	
	if flipped:
		head.offset = Vector2(30, -13)
	else:
		head.offset = Vector2(-30, -13)
	

func animation_finished():
	if health <= 0:
		return
	match head.animation:
		"enraging":
			Main.get_node("Player/MusicPlayer").PlayOnNode(train_sound, self)
			state = states.ENRAGED
		"stunned":
			state = states.STUNNED
			head.play("recovery")
		"recovery":
			head.play("still")
			state = states.STILL


func get_state():
	if state == states.ENRAGED and len(HitCollider.get_overlapping_bodies()) <= 1:
		return states.ENRAGED
		
	if target_player == null:
		return states.STILL
		
	if head.animation == "stunned":
		return states.STUNNED
	
	if head.animation == "recovery":
		return states.RECOVERING
	
	if state == states.ENRAGING:
		return states.ENRAGING
	
	if (global_position.distance_to(target_pos) >= TARGET_RANGE):
		return states.STILL
	
	var yDistance = Vector2(0, global_position.y).distance_to(Vector2(0, target_pos.y))
	var xDistance = Vector2(global_position.x, 0).distance_to(Vector2(target_pos.x, 0))
	
	if (yDistance < RUSH_DISTANCE_ERROR_RANGE or xDistance < RUSH_DISTANCE_ERROR_RANGE) and (head.animation == "enraging" or head.animation == "rushing"):
		return states.ENRAGED
	
	if (yDistance < RUSH_DISTANCE_ERROR_RANGE or xDistance < RUSH_DISTANCE_ERROR_RANGE):
		return states.ENRAGING
	
	if (yDistance >= RUSH_DISTANCE_ERROR_RANGE or xDistance >= RUSH_DISTANCE_ERROR_RANGE):
		return states.WALK


func _on_HitCollider_body_shape_entered(_body_rid, hitBody, _body_shape_index, _local_shape_index):
	if health <= 0:
		return
	if state != states.ENRAGED:
		return
	moveToPos = null
	head.play("stunned")
	body.play("still")
	if hitBody.is_in_group("Player"):
		hitBody.hurt(RAM_DAMAGE)
		return
	if hitBody.is_in_group("Enemy"):
		return
	if hitBody.is_in_group("ground"):
		return
	
