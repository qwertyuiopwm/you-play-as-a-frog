extends RigidBody2D


export var damage = 10
export var VELOCITY = 50
export var DURATION = 5
export var BOUNCES = 0
export var MANA_COST = 15

var remaining_duration = DURATION
var remaining_bounces = BOUNCES


func on_start():
	pass


func on_process():
	pass


func on_settle():
	pass


func hit(body):
	if body.is_in_group("Enemy"):
		body.hurt(damage)


func _ready():
	var mouse_pos = get_global_mouse_position()
	var dir = global_position.direction_to(mouse_pos)
	linear_velocity = dir * VELOCITY
	on_start()


func _process(delta):
	remaining_duration -= delta
	if remaining_duration <= 0:
		on_settle()
		queue_free()
	on_process()
