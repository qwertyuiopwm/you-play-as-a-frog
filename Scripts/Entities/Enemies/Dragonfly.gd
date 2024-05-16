extends "res://Scripts/BaseScripts/Enemy.gd"


export var LAP_SPEED = 200
export var DASH_SPEED = 300
export var DASH_OVERSHOOT_MULTI = 50
export var DASH_COOLDOWN = 0.5
export var ATTACK_COOLDOWN = 1
export var DAMAGE = 5
export var DISTANCE_TO_LAP = 150
export var LAP_COMPLETED_COMFORT_ZONE = 10
export var LAPS_TO_MAKE = 3
export var DASHES = 3


var randomnum = randf()
var state
var lapsCompleted = 0
var dashesCompleted = 0
var dashingPosition


enum states {
	DEFAULT,
	STILL,
	LAPPING,
	DASHING,
	WAITINGTODASH,
}


func _ready():
	$AnimatedSprite.play("default")
	var _obj = $AttackCollider.connect("body_entered", self, "_on_AttackCollider_body_entered")

func on_death():
	$AnimatedSprite.scale = 1.4
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func _physics_process(delta):
	set_target()
	if target_player != null:
		target_pos = target_player.global_position
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
	
	if !target_pos:
		return
	
	match state:
		states.STILL:
			$AnimatedSprite.play("default")
		states.DEFAULT:
			curr_speed = SPEED
			$AnimatedSprite.play("default")
			move(target_pos, delta)
		states.WAITINGTODASH:
			move(dashingPosition, delta)
		states.DASHING:
			if !dashingPosition:
				var rayResult = Main.cast_ray_towards_point(global_position, target_pos, 500, 0b00000000_00000000_00000000_00000001, [])
				dashingPosition = target_pos + (rayResult.normal*-DASH_OVERSHOOT_MULTI)
			
			curr_speed = DASH_SPEED
			move(dashingPosition, delta)
			
			if global_position.distance_to(dashingPosition) <= LAP_COMPLETED_COMFORT_ZONE:
				state = states.WAITINGTODASH
				yield(Main.wait(DASH_COOLDOWN), "completed")
				dashingPosition = null
				state = states.DASHING
				dashesCompleted += 1
				
				if dashesCompleted >= DASHES:
					dashesCompleted = 0
					state = states.STILL
					yield(Main.wait(ATTACK_COOLDOWN), "completed")
					state = states.DEFAULT
		states.LAPPING:
			curr_speed = LAP_SPEED
			var targetLapPosition = target_pos+Vector2(60,-120)
			if lapsCompleted % 2 == 0:
				targetLapPosition = target_pos+Vector2(-60,-120)
			
			move(targetLapPosition, delta)
			
			if global_position.distance_to(targetLapPosition) <= LAP_COMPLETED_COMFORT_ZONE:
				lapsCompleted+=1
			
			if lapsCompleted >= LAPS_TO_MAKE:
				lapsCompleted = 0
				state = states.DASHING


func animation_finished():
	pass


func get_state():
	if target_player == null:
		return states.DEFAULT
	
	if state == states.WAITINGTODASH:
		return states.WAITINGTODASH
	
	if state == states.DASHING:
		return states.DASHING
	
	if state == states.LAPPING:
		return states.LAPPING
	
	if state == states.STILL:
		return states.STILL
	
	if global_position.distance_to(target_player.global_position) <= DISTANCE_TO_LAP:
		return states.LAPPING
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.DEFAULT


func _on_AttackCollider_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(DAMAGE)
