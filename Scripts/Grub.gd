extends KinematicBody2D


export var TARGET_RANGE = 300
export var ATTACK_RANGE = 50
export var SPEED = 50
export var health = 10
#export var CIRCLE_RADIUS = 40
export var SLAM_DAMAGE = 10

onready var rand = RandomNumberGenerator.new()

var velocity = Vector2(0, 0)
var target

enum states {
	STILL,
	INCH,
	ATTACK,
	ATTACKING,
}


var state = states.INCH


func _ready():
	$AnimatedSprite.connect("animation_finished", self, "animation_finished")
	
	
func _physics_process(delta):
	if (target == null) or \
	   (global_position.distance_to(target.global_position) > TARGET_RANGE):
		 target = get_nearest_player()
		
	state = get_state()
	
	
	match state:
		states.STILL:
			$AnimatedSprite.play("still")
		states.INCH:
			$AnimatedSprite.play("walking")
			move(target.global_position, delta)
		states.ATTACK:
			$AnimatedSprite.play("raise")
			state = states.ATTACKING
	

func animation_finished():
	match $AnimatedSprite.animation:
		"raise":
			for body in $SlamCollider.get_overlapping_bodies():
				if !body.is_in_group("Player"): continue
				
				body.health -= SLAM_DAMAGE
			$AnimatedSprite.play("hit")
		"hit":
			state = states.STILL
		


func move(target, delta):
	var direction = (target - global_position).normalized()
	var desired_velocity = direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	if velocity.x > 0: $AnimatedSprite.flip_h = true
	if velocity.x < 0: $AnimatedSprite.flip_h = false
	velocity = move_and_slide(velocity)


func get_state():
	if target == null:
		return states.STILL
	
	if state == states.ATTACKING:
		return states.ATTACKING

	if (global_position.distance_to(target.global_position) <= TARGET_RANGE):
		return states.INCH
	
	if (global_position.distance_to(target.global_position) <= ATTACK_RANGE):
		return states.ATTACK


#func get_circle_position(target, random):
#	var circle_center = target.global_position
#	var angle = random * PI * 2
#	var x = circle_center + cos(angle) * CIRCLE_RADIUS
#	var y = circle_center + sin(angle) * CIRCLE_RADIUS
#
#	return Vector2(x, y)


func get_nearest_player():
	var players = get_tree().get_nodes_in_group("Player")
	var nearest_player
	var lowest_dist = ATTACK_RANGE
	
	for player in players:
		var dist = self.global_position.distance_to(player.global_position)
		if dist >= lowest_dist: continue
		
		nearest_player = player
		lowest_dist = dist
	
	return nearest_player
