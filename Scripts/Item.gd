extends Node2D

enum type {
	Big = 0,
	Small = 1,
}

export var Pickupable := true
export(type) var Type = type.Big

onready var Main = get_node("/root/Main")

func on_pickup(_player):
	pass


func set_pickupable(delay = 0):
	yield(Main.wait(delay), "completed")
	Pickupable = true
