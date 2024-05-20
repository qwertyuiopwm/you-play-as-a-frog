extends "res://Scripts/BaseScripts/Triggerable.gd"


export var DroppedItems = []

var DROP_DIST: float = 75
var DROP_TIME: float = 1
var DROP_DELAY: float = .5
var INITIAL_DROP_DELAY: float = .5

var dropping_item: Node2D
var closed: float = true

func _ready():
	$AnimatedSprite.play("closed" if closed else "open")


func onTrigger(trigger):
	if not trigger: return
	
	closed = false
	$AnimatedSprite.play("open")
	
	yield(Main.wait(INITIAL_DROP_DELAY), "completed")
	
	drop_item()


func drop_item():
	var drop_tween: Tween = Tween.new()
	var item = DroppedItems.pop_back().instance()
	
	call_deferred("add_child", drop_tween)
	call_deferred("add_child", item)
	
	yield(drop_tween, "tree_entered")
	
	var drop_dir = Vector2(randf() - .5, randf() - .5).normalized()
	var drop_pos = drop_dir * DROP_DIST
	
	var _v = drop_tween.interpolate_property(item, "position", 
		Vector2.ZERO, 
		drop_pos, 
		DROP_TIME, Tween.TRANS_QUAD, Tween.EASE_OUT
	)
	var __v = drop_tween.start()
	
	if not DroppedItems:
		return
	
	yield(Main.wait(DROP_DELAY), "completed")
	
	drop_item()
