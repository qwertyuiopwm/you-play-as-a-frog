extends "res://Scripts/BaseScripts/Enemy.gd"


signal enabled

export var CONTACT_DAMAGE: float = 40
export var KNOCKBACK_VELOCITY: Vector2 = Vector2(-200, 0)
export var END_POS_COMFORT_RADIUS: int = 10

export var EndPosPath: NodePath 
export var Enabled := false setget set_Enabled

onready var EndPos = get_node(EndPosPath)

func set_Enabled(val):
	$AnimatedSprite.play("wake up")
	yield($AnimatedSprite, "animation_finished")
	Enabled = val
	emit_signal("enabled")


func _ready():
	var _c = $HitCollider.connect("body_entered", self, "HitCollider_body_entered")
	yield(self, "enabled")
	$AnimatedSprite.play("default")


func hurt(_dmg, _ignore_hit_delay=false):
	pass


func _physics_process(delta):
	if not Enabled:
		return
	
	move(EndPos.global_position, delta)
	
	if global_position.distance_to(EndPos.global_position) < END_POS_COMFORT_RADIUS:
		queue_free()
	
	for body in $BreakTiles.get_overlapping_bodies():
		if body is TileMap and not body.is_in_group("ground"):
			break_tiles()
			break


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
	body.Afflict(Effects.slippy, 1)
	body.velocity = KNOCKBACK_VELOCITY
