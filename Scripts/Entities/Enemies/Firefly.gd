extends "res://Scripts/BaseScripts/Boss.gd"


export var TARGET_COMFORT_RADIUS: int = 10

export var MOVE_ANGLE_OFFSET: int = 5
export var DIST_TO_FOLLOW: int = 200
export var FOLLOW_SPEED_MULT: float = .15

export var MIN_ACTION_DELAY: float = 3
export var MAX_ACTION_DELAY: float = 6

export var ROLL_STEERING_MULT: float = 8
export var LIKELY_ROLL_DIST: float = 75
export(Array, PackedScene) var ROLL_IMMUNITIES = []

export var ROLL_AWAY_SPEED: int = 400
export var ROLL_AWAY_DIST: int = 100
export var NO_ROLL_AWAY_DIST: int = 150

export var ROLL_TOWARDS_SPEED: int = 300
export var ROLL_DAMAGE: int = 15
export var ROLL_TOWARDS_OVERSHOT_DIST: int = 100
export(float, 0, 1) var ROLL_AGAIN_CHANCE: float = .5

export var SHOOT_AMOUNT: int = 5
export var SHOOT_DELAY: float = 1
export var INITIAL_SHOOT_DELAY: float = 2

export var FLAMETHROWER_DURATION: float = 10
export var FLAMETHROWER_STEERING_MULT: float = .25
export var FLAMETHROWER_SPEED: int = 50

export var ProjectileScene: PackedScene

onready var def_scale = Vector2.ONE
onready var roll_scale = Vector2(.7, .7)

enum states {
	DEFAULT,
	ROLLING_AWAY,
	ROLLING_TOWARDS,
	SHOOTING,
	FLAMETHROWERING,
}

const ACTION_FUNCS = {
	states.ROLLING_AWAY: "roll_away",
	states.ROLLING_TOWARDS: "roll_towards",
	states.SHOOTING: "start_shooting",
	states.FLAMETHROWERING: "throw_flames",
}

var state = states.DEFAULT
var state_name
var dist_player
var vel_len: float

var action_counter: float = -1
var shoot_timer: float = 0
var shots_counter: int = 0

func _ready():
	var _c = $RollCollider.connect("body_entered", self, "RollCollider_body_entered")
	target_player = Main.get_node("Player")
	$AnimatedSprite.play("default")
	yield(self, "enabled")
	choose_action([ACTION_FUNCS[states.ROLLING_TOWARDS]])


func on_death():
	scale *= 4
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func RollCollider_body_entered(body):
	if state != states.ROLLING_TOWARDS:
		return
	if not body.is_in_group("Player"):
		return
	
	body.hurt(ROLL_DAMAGE)


func _physics_process(delta):
	dist_player = global_position.distance_to(target_player.global_position)
	state_name = states.keys()[state]
	
	if not Enabled:
		state = states.DEFAULT
		return
	
	if is_sliding():
		move(0, delta)
		return
	
	if state in [states.ROLLING_AWAY, states.ROLLING_TOWARDS]:
		$AnimatedSprite.scale = roll_scale
		curr_steering_mult = ROLL_STEERING_MULT
		curr_immunities = ROLL_IMMUNITIES
	else:
		$AnimatedSprite.scale = def_scale
		curr_steering_mult = STEERING_MULT
		curr_immunities = IMMUNITIES
	
	match state:
		states.DEFAULT:
			curr_speed = SPEED
			curr_steering_mult = STEERING_MULT
			action_counter = -1
			$Flamethrower.Enabled = false
			
			var player_pos = target_player.global_position
			var player_dir: Vector2 = player_pos.direction_to(global_position)
			var player_dist = player_pos.distance_to(global_position)
			
			var rotated_dir = player_dir.rotated(deg2rad(MOVE_ANGLE_OFFSET))
			target_pos = player_pos + rotated_dir * player_dist
			var vel = move(target_pos, delta)
			
			if vel.length() < .1:
				roll_towards()
				return
				
			if player_dist < DIST_TO_FOLLOW:
				return
			
			curr_speed = dist_player * FOLLOW_SPEED_MULT
			move(player_pos, delta)
		
		states.ROLLING_AWAY, states.ROLLING_TOWARDS:
			$AnimatedSprite.play("roll")
			var vel: Vector2 = move(target_pos, delta)
			
			if vel.length() <= .001 or global_position.distance_to(target_pos) < TARGET_COMFORT_RADIUS:
				if state == states.ROLLING_TOWARDS and \
				   randf() < ROLL_AGAIN_CHANCE:
					roll_towards()
					return
				choose_action([ACTION_FUNCS[state]])
				return
		
		states.SHOOTING:
			$AnimatedSprite.play("shoot")
			shoot_timer = max(0, shoot_timer - delta)
			if shoot_timer == 0:
				shoot_timer = SHOOT_DELAY
				shoot_projectile()
				shots_counter -= 1
			
			if shots_counter <= 0:
				choose_action([ACTION_FUNCS[state]])
				yield($AnimatedSprite, "animation_finished")
				return
			
		states.FLAMETHROWERING:
			move(target_player.global_position, delta)
	
	if state == states.DEFAULT:
		return
	
	if action_counter > 0:
		action_counter = max(0, action_counter - delta)
	
	if action_counter == 0:
		choose_action([ACTION_FUNCS[state]])


func choose_action(exclude: Array = []):
	state = states.DEFAULT
	$AnimatedSprite.play("default")
	
	var action_delay: float = rand.randf_range(MIN_ACTION_DELAY, MAX_ACTION_DELAY)
	yield(Main.wait(action_delay), "completed")
	
	var available_actions = []
	
	for item in ACTION_FUNCS.values():
		available_actions.append(item)
	
	for item in exclude:
		if not item in available_actions:
			continue
		available_actions.erase(item)
	
	if global_position.distance_to(target_player.global_position) < LIKELY_ROLL_DIST:
		available_actions.append(ACTION_FUNCS[states.ROLLING_AWAY])
		available_actions.append(ACTION_FUNCS[states.ROLLING_TOWARDS])
	
	if global_position.distance_to(target_player.global_position) > NO_ROLL_AWAY_DIST:
		available_actions.erase(ACTION_FUNCS[states.ROLLING_AWAY])
		
	available_actions.shuffle()
	var selected_action = available_actions[0]
	
	call(selected_action)


func roll_away():
	curr_speed = ROLL_AWAY_SPEED
	var dir = global_position.direction_to(target_player.global_position)
	
	target_pos = global_position - dir * ROLL_AWAY_DIST
	
	state = states.ROLLING_AWAY


func roll_towards():
	curr_speed = ROLL_TOWARDS_SPEED
	var dir = global_position.direction_to(target_player.global_position)
	
	target_pos = target_player.global_position + dir * ROLL_TOWARDS_OVERSHOT_DIST
	
	state = states.ROLLING_TOWARDS


func start_shooting():
	shots_counter = 3
	shoot_timer = INITIAL_SHOOT_DELAY
	state = states.SHOOTING


func throw_flames():
	action_counter = FLAMETHROWER_DURATION
	curr_steering_mult = FLAMETHROWER_STEERING_MULT
	curr_speed = FLAMETHROWER_SPEED
	
	$Flamethrower.Enabled = true
	state = states.FLAMETHROWERING


func shoot_projectile():
	$AnimatedSprite.frame = 0
	var projectile = ProjectileScene.instance()
	
	Main.call_deferred("add_child", projectile)
	projectile.global_position = global_position
