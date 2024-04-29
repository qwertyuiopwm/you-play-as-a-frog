extends Node


onready var parent = get_parent()


func _process(_delta):
	$TextureProgress.max_value = parent.maxHealth
	$TextureProgress.value = parent.health
	
	$slipped.visible = parent.has_effect(Effects.slippy)
	# TODO: implement slowed effect
	#$slowed.visible = parent.has_effect(Effects.slowed)
	$poisoned.visible = parent.has_effect(Effects.poison)
