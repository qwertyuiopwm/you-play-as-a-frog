extends KinematicBody2D


# Declare member variables here. Examples:
export var speed = 400

onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

signal hit


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#var velocity = Vector2.ZERO
	
	#$AnimatedSprite.flip_h = velocity.x < 0
	
	#velocity.y = int(Input.is_action_pressed("move_down")) - \
	#			 int(Input.is_action_pressed("move_up"))
	#velocity.x = int(Input.is_action_pressed("move_right")) - \
	#			 int(Input.is_action_pressed("move_left"))
	
	#if velocity.length() > 0:
		#velocity = velocity.normalized() * speed
		#position += velocity * delta
		#position.x = clamp(position.x, radius, screen_size.x - radius)
		#position.y = clamp(position.y, half_height, screen_size.y - half_height)

		
func _physics_process(delta):
	var velocity = Vector2.ZERO
	velocity.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	velocity.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		move_and_collide(velocity * delta)
