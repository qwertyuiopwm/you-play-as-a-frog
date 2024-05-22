extends Node2D


export var DPS: int = 15
export var Enabled: bool = false


func _physics_process(delta):
	$FlamethrowerSprite.visible = Enabled
	
	if not Enabled:
		return
	
	for body in $Area2D.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt(DPS * delta)
