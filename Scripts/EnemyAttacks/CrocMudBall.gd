extends RigidBody2D


export var SLOW_DURATION: float = 1
export var SLOW_STACKS: int = 1
export var VELOCITY: Vector2 = Vector2(-150, 0)


func _ready():
	var _c = connect("body_entered", self, "body_entered")
	linear_velocity = VELOCITY


func body_entered(body):
	if body is TileMap:
		queue_free()
		return
		
	if not body.is_in_group("Player"):
		return
	
	body.afflict(Effects.slowed, SLOW_DURATION, SLOW_STACKS)
	queue_free()
