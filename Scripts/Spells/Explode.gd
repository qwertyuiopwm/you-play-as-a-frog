extends "res://Scripts/BaseScripts/InstantSpell.gd"

export var ExplosionDamageEnemies = 10
export var ExplosionDamagePlayer = 40


func on_cast(_caster):
	var _c = $AnimatedSprite.play("default")
	
	yield(Main.wait(0.1), "completed")
	var bodies = $HitEntities.get_overlapping_bodies()
	
	var segments = {}
	
	for body in bodies:
		if body.is_in_group("Segment") and "head" in body and not segments.has(body.head):
			segments[body.head] = true
			body.hurt(ExplosionDamageEnemies)
			continue
		
		if body.is_in_group("Segment") and "segments" in body and not segments.has(body):
			segments[body] = true
			body.hurt(ExplosionDamageEnemies)
			continue
		
		if body.is_in_group("Segment"):
			continue
		
		if body.is_in_group("Enemy"):
			body.hurt(ExplosionDamageEnemies)
			continue
		
		if body.is_in_group("Player"):
			body.hurt(ExplosionDamagePlayer)
			continue
	
	yield($AnimatedSprite, "animation_finished")
	queue_free()
