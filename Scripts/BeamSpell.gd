extends "res://Scripts/Spell.gd"


export var TYPE = "beam"

onready var beamLine:Line2D = get_node("Line2D")

var hitCooldown = false

func on_start():
	pass


func on_process():
	pass


func on_settle():
	pass


func hit(body):
	if hitCooldown:
		return
	if body.is_in_group("Enemy"):
		body.hurt(DAMAGE)
		hitCooldown = true
		yield(wait(1), "completed")
		hitCooldown = false


func _ready():
	on_start()


func _physics_process(delta):
	var rootPos = Player.global_position
	var mousePos = get_global_mouse_position()
	
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var rayResult = space_state.intersect_ray(
		rootPos + Vector2(16, 0),
		mousePos - rootPos - Vector2(16, 0),
		[],
		0b00000000_00000000_00000001_00000000
	)
	print(rayResult)
	
	beamLine.global_position = rootPos + Vector2(16, 0)
	beamLine.points[1] = mousePos - rootPos - Vector2(16, 0)

func _process(delta):
	on_process()
