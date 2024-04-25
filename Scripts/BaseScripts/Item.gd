extends Node2D

enum type {
	Big = 0,
	Small = 1,
}

export var Pickupable := true setget pickupable_setter
export(type) var Type = type.Big

onready var Main = get_node("/root/Main")


func pickupable_setter(val):
	Pickupable = val
	$StaticBody2D/CollisionShape2D.disabled = !val


func on_pickup(_player):
	pass


func set_pickupable(delay = 0):
	yield(Main.wait(delay), "completed")
	pickupable_setter(true)
