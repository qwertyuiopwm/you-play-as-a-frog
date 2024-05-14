extends RigidBody2D


export var SLOW_DURATION: float = 1
export var SLOW_STACKS: int = 3
export var SPEED: int = 400

onready var Main = get_node("/root/Main")
onready var Player = Main.get_node("Player")


func _ready():
	var _c = $Area2D.connect("body_entered", self, "body_entered")
	var player_dir = global_position.direction_to(Player.global_position)
	linear_velocity = player_dir * SPEED


func body_entered(body):
	if body is TileMap and body.name != "Rocks":
		queue_free()
		return
		
	if not body.is_in_group("Player"):
		return
	
	body.Afflict(Effects.slowed, SLOW_DURATION, SLOW_STACKS)
	queue_free()
