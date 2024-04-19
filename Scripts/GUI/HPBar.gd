extends Node


onready var parent = get_parent()


func _process(_delta):
	$TextureProgress.max_value = parent.maxHealth
	$TextureProgress.value = parent.health
