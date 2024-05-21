extends RigidBody2D


export var DamagePerSecond = 10
export var TTLSeconds = 5

var secondsAlive = 0

func _ready():
	$AnimatedSprite.play("start")
	yield($AnimatedSprite, "animation_finished")
	$AnimatedSprite.play("loop")
	
func _physics_process(delta):
	secondsAlive+=delta
	if secondsAlive >= TTLSeconds:
		queue_free()
		return
	
	var bodies = $DamageCollider.get_overlapping_bodies()
	
	for body in bodies:
		if not body.is_in_group("Player"):
			continue
		body.hurt(DamagePerSecond * delta, true)
