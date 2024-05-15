extends "res://Scripts/BaseScripts/Enemy.gd"


export var BITE_DAMAGE: float = 10
export var POISON_STACKS: int = 5
export var POISON_DURATION: float = 10
export var BABY_SPAWN_DIST: int = 25
export var BABY_SPIDERS_SPAWNED: int = 0
export var BabySpiderScene: PackedScene

enum states {
	STILL,
	FOLLOW,
	BITING,
}

var state


func _ready():
	var _c = $HitCollider.connect("body_entered", self, "_HitCollider_body_entered")
	var __c = $AnimatedSprite.connect("animation_finished", self, "_animation_finished")

func on_death():
	$AnimatedSprite.play("death")
	
	for _x in range(BABY_SPIDERS_SPAWNED):
		var inst = BabySpiderScene.instance()
		Main.call_deferred("add_child", inst)
		
		var x = rand.randi_range(-BABY_SPAWN_DIST, BABY_SPAWN_DIST)
		var y = rand.randi_range(-BABY_SPAWN_DIST, BABY_SPAWN_DIST)
		
		inst.global_position = global_position + Vector2(x, y)
	
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")

func _physics_process(delta):
	if health <= 0:
		return
	set_target()
	if target_player != null:
		target_pos = target_player.global_position
	state = get_state()
	
	if is_sliding():
		move(0, delta)
		return
	
	var flip_h = $AnimatedSprite.flip_h
	if flip_h:
		$HitCollider.rotation_degrees = 180
	
	match state:
		states.BITING:
			pass
		states.STILL:
			$AnimatedSprite.play("still")
		
		states.FOLLOW:
			$AnimatedSprite.play("walk")
			move(target_pos, delta)


func get_state():
	if target_player == null:
		return states.STILL
	
	if state == states.BITING:
		return states.BITING
		
	if (global_position.distance_to(target_player.global_position) <= TARGET_RANGE):
		return states.FOLLOW


func _HitCollider_body_entered(body):
	if health <= 0:
		return
	if $AnimatedSprite.animation == "bite":
		return
	if not body.is_in_group("Player"):
		return
		
	state = states.BITING
	$AnimatedSprite.play("bite")

func _animation_finished():
	if health <= 0:
		return
	if $AnimatedSprite.animation != "bite":
		return
	
	for body in $HitCollider.get_overlapping_bodies():
		if body.is_in_group("Player"):
			body.hurt(BITE_DAMAGE, true)
			body.Afflict(Effects.poison, POISON_DURATION, POISON_STACKS)
	
	state = states.STILL
	
