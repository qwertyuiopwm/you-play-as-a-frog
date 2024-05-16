extends "res://Scripts/BaseScripts/Boss.gd"


#export var

enum states {
	STILL,
	ROLL,
}

var state = states.STILL


func _ready():
	$AnimatedSprite.play("default")


func on_death():
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func _physics_process(delta):
	set_target()
	
	if not Enabled:
		return
	
	if is_sliding():
		move(0, delta)
		return
	
	match state:
		states.STILL:
			pass


func roll(end_pos: Vector2):
	pass
