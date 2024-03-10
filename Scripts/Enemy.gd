tool
extends "res://Scripts/Entity.gd"


export var TARGET_RANGE = 300
export var ATTACK_RANGE = 50
export var SPEED = 50
export var health = 10

var STEERING_MULT = 2.5

onready var Main = get_node("/root/Main")
onready var rand = RandomNumberGenerator.new()
onready var debug = OS.is_debug_build()

var velocity = Vector2(0, 0)
var curr_speed = SPEED
var target_player
var target_pos

var sliding = false


func animation_finished():
	assert(false, "Script does not override animation_finished method!")


func get_state():
	assert(false, "Script does not override get_state method!")


func hurt(damage):
	health = max(health - damage, 0)
	
	if health == 0:
		queue_free()


func _ready():
	$AnimatedSprite.connect("animation_finished", self, "animation_finished")


func set_target():
	if (target_player == null) or \
	   (global_position.distance_to(target_player.global_position) > TARGET_RANGE):
		 target_player = get_nearest_player()


func move(_target, delta):
	if not Main.GameStarted:
		return
	
	if sliding and velocity.length_squared() == 0:
		move_and_slide(velocity)
		return
	
	var direction = (_target - global_position).normalized()
	var desired_velocity = direction * curr_speed
	var steering = (desired_velocity - velocity) * delta * STEERING_MULT
	velocity += steering
	if velocity.x > 0: $AnimatedSprite.flip_h = true
	if velocity.x < 0: $AnimatedSprite.flip_h = false
	velocity = move_and_slide(velocity)


func get_circle_position(random, circle_radius):
	var circle_center = target_player.global_position
	var angle = random * PI * 2
	var x = circle_center.x + cos(angle) * circle_radius
	var y = circle_center.y + sin(angle) * circle_radius

	return Vector2(x, y)


func get_nearest_player():
	var players = get_tree().get_nodes_in_group("Player")
	var nearest_player
	var lowest_dist = TARGET_RANGE
	
	for player in players:
		var dist = self.global_position.distance_to(player.global_position)
		if dist >= lowest_dist: continue
		
		nearest_player = player
		lowest_dist = dist
	
	return nearest_player
