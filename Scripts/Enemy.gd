tool
extends "res://Scripts/Entity.gd"


export var TARGET_RANGE = 300
export var ATTACK_RANGE = 50
export var SPEED = 50
export var SLIP_WALL_DAMAGE = 10
export var SLIP_SPEED_MULT = 	2
export var STEERING_MULT = 2.5
export var ROTATE_TO_TARGET = false

export var health: float = 10


onready var Main = get_node("/root/Main")
onready var rand = RandomNumberGenerator.new()
onready var debug = OS.is_debug_build()

onready var curr_speed = SPEED

var velocity = Vector2(0, 0)
var target_player
var target_pos


func animation_finished():
	pass


func get_state():
	assert(false, "Script does not override get_state method!")


func hurt(damage: float):
	health = max(health - damage, 0)
	
	if health == 0:
		on_death()
		queue_free()


func on_death():
	pass


func _ready():
	for child in get_children():
		if not child is AnimatedSprite:
			continue
		var _obj = child.connect("animation_finished", self, "animation_finished")


func set_target():
	if target_player and !player_in_sight(target_player):
		target_player = null
		return
	if (target_player == null) or \
	   (global_position.distance_to(target_player.global_position) > TARGET_RANGE):
		 target_player = get_nearest_player()


func move(_target, delta):
	if not Main.GameStarted or not can_move:
		return
	
	if ROTATE_TO_TARGET:
		rotation = Vector2.ZERO.angle_to_point(velocity)
	
	if sliding and velocity.length_squared() != 0:
		var body = move_and_collide(velocity * SLIP_SPEED_MULT * delta)
		
		if body == null:
			return
			
		if body.collider.get_parent().get_children()[0] is TileMap:
			hurt(SLIP_WALL_DAMAGE)
			Cure(Effects.slippy)
		return
	
	var direction = (_target - global_position).normalized()
	var desired_velocity = direction * curr_speed
	var steering = (desired_velocity - velocity) * delta * STEERING_MULT
	velocity += steering
	flip_body(velocity.x > 0)
	velocity = move_and_slide(velocity)


func flip_body(flipped):
	$AnimatedSprite.flip_h = flipped


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
		
		#TODO if cant see player, continue
		
		nearest_player = player
		lowest_dist = dist
	
	if nearest_player == null:
		return
	
	if !player_in_sight(nearest_player):
		return
	
	return nearest_player

func player_in_sight(player):
	if player == null:
		return false
	
	var playerCollision = player.get_node("CollisionShape2D")
	if playerCollision == null:
		return false
	
	var playerPos = player.global_position
	var collisionRadius = playerCollision.shape.radius
	var collisionHeight = playerCollision.shape.height
	
	var targetPositions = [Vector2(
			playerPos.x-collisionRadius,
			playerPos.y-(collisionHeight)
		),Vector2(
			playerPos.x+collisionRadius,
			playerPos.y-(collisionHeight)
		),Vector2(
			playerPos.x-collisionRadius,
			playerPos.y+(collisionHeight)
		),Vector2(
			playerPos.x+collisionRadius,
			playerPos.y+(collisionHeight)
		)]
	
	for p in targetPositions:
		var rayResult = Main.cast_ray(self.global_position, p, 0b00000000_00000000_00000000_00001001, [self])
		if not rayResult.has("position"):
			continue
		if rayResult.collider == player:
			return true
	
	return false
