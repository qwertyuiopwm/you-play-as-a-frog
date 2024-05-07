extends "res://Scripts/BaseScripts/Enemy.gd"


export var SLAM_DAMAGE = 10


enum states {
	STILL,
	INCH,
	ATTACK,
	ATTACKING,
}


var state = states.INCH


func on_death():
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
	
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
		states.INCH:
			$AnimatedSprite.play("walking")
			move(target_pos, delta)
		states.ATTACK:
			$AnimatedSprite.play("raise")
			state = states.ATTACKING
	

func animation_finished():
	match $AnimatedSprite.animation:
		"raise":
			for body in $SlamCollider.get_overlapping_bodies():
				if !body.is_in_group("Player"): continue
				
				body.hurt(SLAM_DAMAGE)
			$AnimatedSprite.play("hit")
		"hit":
			state = states.STILL


func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.ATTACKING:
		return states.ATTACKING
	
	if (global_position.distance_to(target_pos) <= ATTACK_RANGE):
		return states.ATTACK

	if (global_position.distance_to(target_pos) <= TARGET_RANGE):
		return states.INCH
