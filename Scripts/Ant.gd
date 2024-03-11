extends "res://Scripts/Enemy.gd"


export var CIRCLE_RADIUS = 100
export var BITE_DAMAGE = 10
export var TARGET_COMFORT_RADIUS = 10


enum states {
	STILL,
	CIRCLE,
	SWARM,
	BITE,
	BITING,
}


var state
var randomnum = randf()


func _physics_process(delta):
	set_target()
	state = get_state()
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
		states.CIRCLE:
			$AnimatedSprite.play("walk")
			target_pos = get_circle_position(randomnum, CIRCLE_RADIUS)
			move(target_pos, delta)
			
		states.SWARM:
			move(target_player.global_position, delta)


func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.BITING:
		return states.BITING
		
	if (global_position.distance_to(target_player.global_position) <= ATTACK_RANGE):
		$AnimatedSprite.play("ready_attack")
		return states.BITING
	
	if state == states.SWARM:
		return states.SWARM
		
	if state == states.CIRCLE and global_position.distance_to(target_pos) <= TARGET_COMFORT_RADIUS:
		return states.SWARM
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.CIRCLE


func animation_finished():
	match $AnimatedSprite.animation:
		"ready_attack":
			for body in $HitCollider.get_overlapping_bodies():
				if !body.is_in_group("Player"): continue
				
				body.Hurt(BITE_DAMAGE)
			$AnimatedSprite.play("hit")
		"hit":
			state = states.STILL
