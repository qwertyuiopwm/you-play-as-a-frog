extends "res://Scripts/BaseScripts/Enemy.gd"


export var BREAK_DELAY: float = 1
export var CONTACT_DAMAGE: float = 40
export var KNOCKBACK_VELOCITY: Vector2 = Vector2(-200, 0)

export var Enabled := false

enum states {
	MOVING,
	BREAKING,
}


var state = states.MOVING


func _ready():
	var _c = $HitCollider.connect("body_entered", self, "HitCollider_body_entered")


func on_death():
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func _physics_process(delta):
	if not Enabled:
		return
	
	move(global_position + Vector2(-1, 0), delta)
	
	if state == states.BREAKING:
		return
	
	for body in $BreakTiles.get_overlapping_bodies():
		if body is TileMap and not body.is_in_group("ground"):
			state = states.BREAKING
			break_tiles()
			break


func break_tiles():
	yield(Main.wait(1), "completed")
	$BreakTiles.break_tiles()
	state = states.MOVING


func HitCollider_body_entered(body):
	if not body.is_in_group("Player"):
		return
	
	body.hurt(CONTACT_DAMAGE)
	body.Afflict(Effects.slippy, 1)
	body.velocity = KNOCKBACK_VELOCITY
