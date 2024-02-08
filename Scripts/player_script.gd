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

func _on_DEATH_animation_finished():
	$DEATH.visible = false
	$CollisionShape2D.disabled = true

func Hurt(dmg: int):
	if health <= 0:
		return
	var newHp = health - dmg
	if newHp <= 0:
		$PlayerSprite.visible = false
		$DEATH.visible = true
		$DEATH.play("explosion")
		pass
	
	health = newHp

func Heal(hp: int):
	if health <= 0:
		return
	var newHp = health + hp
	if newHp > maxHealth:
		newHp = maxHealth
	
	health = newHp

func _physics_process(delta):
	if health <= 0:
		return
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
	
		if velocity.y > 0: $PlayerSprite.play("down")
		if velocity.y < 0: $PlayerSprite.play("up")
		if velocity.y == 0:
			if velocity.x > 0: $PlayerSprite.play("right")
			if velocity.x < 0: $PlayerSprite.play("left")

