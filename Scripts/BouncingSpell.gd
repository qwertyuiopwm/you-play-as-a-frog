extends "res://Scripts/Spell.gd"


export var TYPE = "BOUNCING"
export var VELOCITY = 50
export var DURATION = 5
export var BOUNCES = 0

var remaining_duration = DURATION
var remaining_bounces = BOUNCES


func on_start():
	pass


func on_process():
	pass


func on_settle(body):
	pass


func collide(body_rid, body, body_shape_index, local_shape_index):
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
		on_settle(body)
		queue_free()


func _ready():
	var mouse_pos = get_global_mouse_position()
	var dir = global_position.direction_to(mouse_pos)
	linear_velocity = dir * VELOCITY
	connect("body_shape_entered", self, "collide")
	on_start()


func _process(delta):
	remaining_duration -= delta
	if remaining_duration <= 0:
		on_settle(null)
		queue_free()
	on_process()


func try_cast(player):
	if player.mana < MANA_COST: 
		queue_free()
		return
	
	player.mana -= MANA_COST
	global_position = player.global_position
	player.get_parent().add_child(self)
