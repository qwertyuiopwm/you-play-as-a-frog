extends KinematicBody2D


export var speed = 400

onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

var maxHealth = 100
var health = maxHealth

func _ready():
	$MusicPlayer.PlaySong($MusicPlayer.CurrentlyPlaying)
	pass

func _physics_process(delta):
	var velocity = Vector2.ZERO
	velocity.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	velocity.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	if velocity.length() <= 0:
		$PlayerSprite.frame = 0
		$PlayerSprite.stop()
		return
		
	velocity = velocity.normalized() * speed
	
	var velocityX = Vector2(velocity.x, 0)
	move_and_collide(velocityX * delta)
	
	var velocityY = Vector2(0, velocity.y)
	move_and_collide(velocityY * delta)

	if velocity.y > 0: $PlayerSprite.play("down")
	if velocity.y < 0: $PlayerSprite.play("up")
	if velocity.y == 0:
		if velocity.x > 0: $PlayerSprite.play("right")
		if velocity.x < 0: $PlayerSprite.play("left")
