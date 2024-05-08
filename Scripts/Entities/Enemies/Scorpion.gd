extends "res://Scripts/BaseScripts/Enemy.gd"


export var MIN_CIRCLE_RADIUS = -30
export var STING_DAMAGE = 20
export var TARGET_COMFORT_RADIUS = 10

enum states {
	STILL,
	FOLLOW,
}

var radius_dist_mult = 1

var target_radius
var state
var randomnum = randf()


func _ready():
	var _c = $DetectorCollider.connect("body_entered", self, "StingCollider_body_entered")
	var __c = $TailSprite.connect("animation_finished", self, "TailSprite_animation_finished")

func on_death():
	$TailSprite.visible = false
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")

func _physics_process(delta):
	if health <= 0:
		return
	set_target()
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
	var flip_h = $AnimatedSprite.flip_h
	$TailSprite.flip_h = flip_h
	$TailSprite.position = $TailLeft.position if flip_h else \
						  $TailRight.position
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
		
		states.FOLLOW:
			$AnimatedSprite.play("walk")
			var dist = global_position.distance_squared_to(target_player.global_position)
			target_radius = MIN_CIRCLE_RADIUS + (radius_dist_mult * pow(dist, .5))
			
			target_pos = get_circle_position(randomnum, target_radius)
			move(target_pos, delta)


func get_state():
	if target_player == null:
		return states.STILL
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.FOLLOW


func StingCollider_body_entered(body):
	if health <= 0:
		return
	if $TailSprite.animation == "sting":
		return
	if not body.is_in_group("Player"):
		return
	
	$TailSprite.play("sting")
	$DetectorCollider/CollisionShape2D.set_deferred("disabled", true)


func TailSprite_animation_finished():
	if health <= 0:
		return
	if $TailSprite.animation != "sting":
		return
	
	for body in $HitCollider.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt(STING_DAMAGE, true)
			body.Afflict(Effects.poison, 5, 8)
	
	$TailSprite.play("still")
	yield(Main.wait(1.5), "completed")
	$DetectorCollider/CollisionShape2D.set_deferred("disabled", false)
