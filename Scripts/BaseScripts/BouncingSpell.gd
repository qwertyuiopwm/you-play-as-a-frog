extends "res://Scripts/BaseScripts/Spell.gd"

signal settled

export var TYPE = "BOUNCING"
export var VELOCITY = 50
export var DURATION = 5
export var BOUNCES = 0

var remaining_duration = DURATION
var remaining_bounces = BOUNCES
var target
var dir


func on_start():
	pass


func on_process():
	pass


func on_settle(_body):
	pass


func collide(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.collision_layer&EnemyCollision:
		hit(body)

	if body.collision_layer&WallCollision or \
		body.collision_layer&EnemyCollision:
		bounce(body)


func hit(body):
	hurt(body, DAMAGE)


func bounce(body):
	BOUNCES -= 1
	if BOUNCES < 0:
		on_settle(null)
		yield(self, "settled")
		queue_free()



func _process(delta):
	remaining_duration -= delta
	if remaining_duration <= 0:
		on_settle(null)
		yield(self, "settled")
		queue_free()
	on_process()


func try_cast(player):
	if player.mana < MANA_COST: 
		queue_free()
		return
	
	player.get_parent().add_child(self)
	
	target = player.get_target(BlockedEffects, BlockedImmunities)
	
	var target_pos = target.global_position
	
	player.mana -= MANA_COST
	
	global_position = player.global_position
	dir = global_position.direction_to(target_pos)
	linear_velocity = dir * VELOCITY
	
	var _obj = connect("body_shape_entered", self, "collide")
	on_start()
