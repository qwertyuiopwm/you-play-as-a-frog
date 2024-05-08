extends "res://Scripts/BaseScripts/Triggerable.gd"


export var DroppedItems = []

var DROP_DIST = 75
var DROP_SPEED = 75
enum states {
	CLOSED,
	OPENING,
	OPEN,
}

var state = states.CLOSED
var dropping_item: Node2D
var drop_dir: Vector2


func onTrigger(trigger):
	if not trigger: return
	
	state = states.OPENING
	$AnimatedSprite.frame = 1


func _process(delta):
	if state != states.OPENING: return
	if dropping_item == null and len(DroppedItems) <= 0: return
	
	if dropping_item == null or global_position.distance_to(dropping_item.global_position) > DROP_DIST:
		if not DroppedItems:
			dropping_item.Pickupable = true
			state = states.OPEN
			return
		
		if dropping_item != null:
			dropping_item.Pickupable = true
		
		dropping_item = DroppedItems.pop_back().instance()
		dropping_item.Pickupable = false
		get_parent().add_child(dropping_item)
		dropping_item.global_position = global_position
		drop_dir = Vector2(randf() - .5, randf() - .5)
		drop_dir = drop_dir.normalized()
	
	dropping_item.global_position += drop_dir * DROP_SPEED * delta
	
