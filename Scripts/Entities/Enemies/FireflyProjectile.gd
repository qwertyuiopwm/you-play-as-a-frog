extends RigidBody2D


export var SPEED: int = 400
export var DAMAGE: int = 10

export var ResidueScene: PackedScene

onready var Main = get_node("/root/Main")
onready var Player = Main.get_node("Player")


func _ready():
	var _c = $Area2D.connect("body_entered", self, "body_entered")
	var player_dir = global_position.direction_to(Player.global_position)
	linear_velocity = player_dir * SPEED
	rotation = player_dir.angle()
	print(linear_velocity, rotation)


func body_entered(body):
	if body is TileMap and body.name != "Rocks":
		queue_free()
		return
		
	if not body.is_in_group("Player"):
		return
	
	body.hurt(DAMAGE)
	
	var residue = ResidueScene.instance()
	
	queue_free()
