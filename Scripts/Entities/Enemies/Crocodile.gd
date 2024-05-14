extends "res://Scripts/BaseScripts/Boss.gd"


export var CONTACT_DAMAGE: float = 40
export var KNOCKBACK_VELOCITY: Vector2 = Vector2(-700, 0)
export var SPEED_UP_DIST: int = 700
export var SPEED_DIST_MULT: float = 1
export var SPEED_UP_DELAY: float = 6
export var END_SPEED: int = 150

export var EndAligningPosPath: NodePath
export var EndPosPath: NodePath

onready var EndAligningPos = get_node(EndAligningPosPath)
onready var EndPos = get_node(EndPosPath)

var speed_up = false
var aligning := true


func _ready():
	target_player = Main.get_node("Player")
	var _c = $HitCollider.connect("body_entered", self, "HitCollider_body_entered")
	
	yield(self, "enabled")
	
	$AnimatedSprite.play("wake up")
	yield($AnimatedSprite, "animation_finished")
	
	$AnimatedSprite.play("default")
	
	yield(Main.wait(SPEED_UP_DELAY), "completed")
	speed_up = true


func hurt(_dmg, _ignore_hit_delay=false):
	pass


func _physics_process(delta):
	if not Enabled:
		return
	
	move_forward(delta)
	
	if global_position.x - EndAligningPos.global_position.x < 0:
		aligning = false
		$HitCollider/CollisionShape2D.disabled = true
	
	if global_position.x - EndPos.global_position.x < 0:
		queue_free()
	
	for body in $BreakTiles.get_overlapping_bodies():
		if body is TileMap and not body.is_in_group("ground"):
			break_tiles()
			break


func move_forward(delta):
	var player_x_dist = abs(global_position.x - target_player.global_position.x)
	
	if player_x_dist > SPEED_UP_DIST and speed_up:
		curr_speed = SPEED + (player_x_dist - SPEED_UP_DIST) * SPEED_DIST_MULT
	
	if not aligning:
		curr_speed = END_SPEED
		move(EndPos.global_position, delta)
		return
	
	var moveVector = Vector2(EndPos.global_position.x, global_position.y)
	move(moveVector, delta)

	var alignVector = Vector2(global_position.x, target_player.global_position.y)
	move(alignVector, delta)


func on_death():
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func break_tiles():
	$BreakTiles.break_tiles()


func HitCollider_body_entered(body):
	if not body.is_in_group("Player"):
		return
	
	body.hurt(CONTACT_DAMAGE)
	body.Afflict(Effects.slippy, .2)
	body.velocity = KNOCKBACK_VELOCITY
