extends "res://Scripts/Enemy.gd"


export var RAM_DAMAGE = 10
export var RUSH_SPEED_MULT = 5
export var VERT_DISTANCE_TO_RUSH = 10

onready var head = $head
onready var body = $AnimatedSprite
onready var HitCollider = $HitCollider

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
	
	
func _physics_process(delta):
	set_target()
	if target_player == null:
		return
	
	target_pos = target_player.global_position
	state = get_state()
	
	if state == states.ENRAGED:
		if moveToPos == null:
			moveToPos = target_pos
			var rayResult = Main.cast_ray_towards_point(global_position, target_pos, 900, 0b00000000_00000000_00000000_00001000, [])
			if rayResult.has("position"):
				moveToPos = rayResult.position
	
	
	match state:
		states.STILL:
			body.play("still")
			head.play("still")
		states.WALK:
			curr_speed = SPEED
			body.speed_scale = 1
			body.play("walk_vert")
			head.play("still")
			move(Vector2(global_position.x, target_pos.y), delta)
		states.ENRAGING:
			body.play("still")
			head.play("enraging")
		states.ENRAGED:
			curr_speed = SPEED * RUSH_SPEED_MULT
			body.speed_scale = 1.5
			head.play("rushing")
			body.play("walk_horo")
			move(moveToPos, delta)
	

func flip_body(flipped):
	body.flip_h = flipped
	head.flip_h = flipped
	
	if flipped:
		HitCollider.position = Vector2(35, 4)
		head.offset = Vector2(30, -13)
	else:
		HitCollider.position = Vector2(-35, 4)
		head.offset = Vector2(-30, -13)
	

func animation_finished():
	match head.animation:
		"enraging":
			state = states.ENRAGED
		"stunned":
			state = states.RECOVERING
		"recovery":
			state = states.STILL


func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.ENRAGING:
		return states.ENRAGING
	
	if state == states.ENRAGED and len(HitCollider.get_overlapping_bodies()) <= 1:
		return states.ENRAGED
	
	if (global_position.distance_to(target_pos) >= TARGET_RANGE):
		return states.STILL
	
	var yDistance = Vector2(0, global_position.y).distance_to(Vector2(0, target_pos.y))
	
	if yDistance < VERT_DISTANCE_TO_RUSH and (head.animation == "enraging" or head.animation == "rushing"):
		return states.ENRAGED
	
	if yDistance < VERT_DISTANCE_TO_RUSH:
		return states.ENRAGING
	
	if yDistance >= VERT_DISTANCE_TO_RUSH:
		return states.WALK



func _on_HitCollider_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if state != states.ENRAGED:
		return
	moveToPos = null
	if body.is_in_group("Player"):
		print("hit player!")
		return
	if body.is_in_group("Enemy"):
		print("Hit another enemy :(")
		return
	if body.is_in_group("ground"):
		print("Hit a wall :(")
		return
	
