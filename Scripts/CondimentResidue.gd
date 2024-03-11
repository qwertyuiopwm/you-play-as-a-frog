extends Node2D


export var SLIPPY_DURATION = 1.5
export master var DURATION = 15

var counter = 0


func _ready():
	$Sprite.play("default")


func _process(delta):
	counter += delta
	if counter >= DURATION:
		queue_free()


func _on_Area2D_body_entered(body):
	if body is Entity:
		body.Afflict(Effects.slippy, SLIPPY_DURATION)
		queue_free()
