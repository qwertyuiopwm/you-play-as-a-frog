extends KinematicBody2D


# Declare member variables here. Examples:
export var speed = 400

onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

var health = 100

		
func _physics_process(delta):
	var velocity = Vector2.ZERO
	velocity.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	velocity.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
		var velocityX = Vector2(velocity.x, 0)
		move_and_collide(velocityX * delta)
		
		var velocityY = Vector2(0, velocity.y)
		move_and_collide(velocityY * delta)
		
		if velocity.x > 0: set_flip(true)
		if velocity.x < 0: set_flip(false)

func set_flip(flip_h):
	for node in $PlayerSprite.get_children():
		node.flip_h = flip_h
