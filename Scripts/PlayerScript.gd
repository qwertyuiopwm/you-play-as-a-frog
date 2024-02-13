extends KinematicBody2D


export var SPEED = 400
export var spells = [
	preload("res://Spells/ProcureCondiment.tscn")
]
export var selected_spell: PackedScene = spells[0]

onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

var maxHealth = 100
var health = maxHealth
var sliding_velocity = Vector2.ZERO


func _ready():
	$MusicPlayer.PlaySong($MusicPlayer.CurrentlyPlaying)

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
	
	if Input.is_action_just_pressed("cast_spell"):
		cast_spell()
	
	var velocity = Vector2.ZERO
	velocity.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	velocity.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	if velocity.length() <= 0:
		$PlayerSprite.frame = 0
		$PlayerSprite.stop()
		return
	
	velocity = velocity.normalized() * SPEED
	
	move_and_slide(velocity)
	
	set_animation(velocity)


func cast_spell():
	var spell = selected_spell.instance()
	spell.global_position = global_position
	get_parent().add_child(spell)


func set_animation(velocity):
	if velocity.y > 0: 
		$PlayerSprite.play("down")
	if velocity.y < 0: 
		$PlayerSprite.play("up")
	if velocity.y == 0:
		if velocity.x > 0: 
			$PlayerSprite.play("right")
		if velocity.x < 0: 
			$PlayerSprite.play("left")
	
	
