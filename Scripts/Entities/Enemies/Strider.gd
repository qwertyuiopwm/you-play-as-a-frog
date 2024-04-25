extends "res://Scripts/BaseScripts/Enemy.gd"


export var CHARGE_DAMAGE = 10
export var TARGET_COMFORT_RADIUS = 10

var MAX_CHARGE_DIST = 500

enum states {
	STILL,
	CHARGE,
	CHARGING,
	RECOVERING,
}


var state
var randomnum = randf()


func _physics_process(delta):
	set_target()
	
	if is_sliding():
		move(0, delta)
		return
	
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
			if target_player == null:
				return
			
			state = states.CHARGE
		
		states.CHARGE:
			$AnimatedSprite.play("ready_charge")
			
			var dir_to_player = global_position.direction_to(target_player.global_position)
			target_pos = global_position + dir_to_player * MAX_CHARGE_DIST
		
		states.CHARGING:
			$AnimatedSprite.play("charge")
			
			move(target_pos, delta)
			
			for body in $HitCollider.get_overlapping_bodies():
				if not body.is_in_group("Player"):
					return
				
				body.Hurt(CHARGE_DAMAGE)
				state = states.RECOVERING
				continue
		
		states.RECOVERING:
			$AnimatedSprite.play("recover")


func animation_finished():
	match $AnimatedSprite.animation:
		"ready_charge":
			state = states.CHARGING
		"charge":
			state = states.RECOVERING
		"recover":
			state = states.STILL
