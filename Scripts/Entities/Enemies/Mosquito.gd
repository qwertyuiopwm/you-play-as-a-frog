extends "res://Scripts/BaseScripts/Enemy.gd"


export var TARGET_OFFSET = Vector2(50, -50)
export var SWOOP_SPEED = 150
export var SWOOP_DIST = 150
export var DAMAGE = 5

var TARGET_COMFORT_RADIUS = 20

var randomnum = randf()
var state


enum states {
	DEFAULT,
	ALIGN,
	SWOOP,
	SWOOPING,
}


func _ready():
	$AnimatedSprite.play("default")
	var _obj = $AttackCollider.connect("body_entered", self, "_on_AttackCollider_body_entered")
	$targ_vis.visible = debug


func _process(_delta):
	set_target()
	state = get_state()


func _physics_process(delta):
	curr_speed = SWOOP_SPEED if state == states.SWOOPING \
		else SPEED
	
	print(state)
	
	if target_pos: $targ_vis.global_position = target_pos
	if state == states.SWOOPING: modulate = Color(1, .9, .9)
	else: modulate = Color(1, 1, 1)
	
	if is_sliding():
		move(0, delta)
		return
	
	match state:
		states.DEFAULT:
			if not target_player:
				return
		
		states.SWOOPING:
			move(target_pos, delta)
		
		states.SWOOP:
			target_pos = global_position + global_position.direction_to(target_player.global_position) * SWOOP_DIST
			state = states.SWOOPING
		
		states.ALIGN:
			var player_pos = target_player.global_position
			var dir_to_player = global_position.direction_to(player_pos)
			var x_dir = dir_to_player.x
			x_dir /= abs(x_dir)
			var offset = Vector2(-x_dir, 1) * TARGET_OFFSET
			
			target_pos = player_pos + offset
			move(target_pos, delta)


func get_state():
	if state == states.SWOOPING:
		if global_position.distance_to(target_pos) < TARGET_COMFORT_RADIUS:
			return states.DEFAULT
		return states.SWOOPING
	
	if target_player == null or target_pos == null:
		return states.DEFAULT
	
	if global_position.x < target_pos.x:
		return states.SWOOP
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.ALIGN


func _on_AttackCollider_body_entered(body):
	if body.is_in_group("Player"):
		body.Hurt(DAMAGE)
