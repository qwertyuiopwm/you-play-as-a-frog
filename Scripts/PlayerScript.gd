extends "res://Scripts/Entity.gd"


export var SPEED = 400
export var HELD_ITEM_POS: Vector2
export var spells = [
	preload("res://Spells/ProcureCondiment.tscn"),
	preload("res://Spells/DevBeam.tscn"),
]
export var selected_spell: PackedScene
export var god_enabled: bool

onready var Main = get_node("/root/Main")
onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

export var damage_mult = 1
export var max_health: float = 100
export var health: float = 100
var regen_delay = 10
var health_per_second = 1
var regen_timer = 0

var max_mana = 100
var mana = max_mana
var mana_per_second = 7
var beam: RigidBody2D

var max_stamina = 100
var stamina = max_stamina
var stamina_per_second = 10

var velocity = Vector2.ZERO
var sliding = false

var currentFocus: Control

var held_big_item: Node2D


func _ready():
	get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")

func _remove_focus():
	currentFocus.disconnect("focus_exited", self, "_remove_focus")
	currentFocus = null

func _on_focus_changed(node):
	if node == null:
		return
	currentFocus = node
	currentFocus.connect("focus_exited", self, "_remove_focus")

func _physics_process(delta):
	if not Main.GameStarted:
		return
	if health <= 0:
		return
	
	var curr_tile: String = get_curr_tile()
	
	sliding = "(slide)" in curr_tile
	
	regen_stats(delta)
	
	cast_spell_if_pressed(delta)
	
	set_velocity()
	
	if velocity.length() <= 0:
		$PlayerSprite.frame = 0
		$PlayerSprite.stop()
		return
	
	set_animation()
	move_and_slide(velocity)
	
	if held_big_item != null:
		held_big_item.global_position = $ItemHolder.global_position


func _on_DEATH_animation_finished():
	$DEATH.visible = false
	$CollisionShape2D.disabled = true


func get_curr_tile():
	for tile_map in get_tree().get_nodes_in_group("ground"):
		var pos = tile_map.world_to_map(global_position) - tile_map.world_to_map(tile_map.global_position)
		var tile_id = tile_map.get_cellv(pos)
		if tile_id != -1:
			return tile_map.tile_set.tile_get_name(tile_id)
	return "did not find tile"


func Hurt(dmg: float):
	if god_enabled:
		return
	if health <= 0:
		return
	
	regen_timer = regen_delay
	
	var newHp = health - dmg
	if newHp <= 0:
		$PlayerSprite.visible = false
		$DEATH.visible = true
		$DEATH.play("explosion")
		pass
	
	health = newHp


func Heal(hp: float):
	if health <= 0:
		return
	var newHp = health + hp
	if newHp > max_health:
		newHp = max_health
	
	health = newHp


func set_velocity():
	if sliding and velocity.length_squared() == 0: return
	if currentFocus != null: return
	
	velocity.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	velocity.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	velocity = velocity.normalized() * SPEED


func regen_stats(delta):
	if regen_timer == 0:
		Heal(health_per_second * delta)
	else: 
		regen_timer = max(regen_timer - delta, 0)
	if beam == null:
		mana = clamp(mana + (mana_per_second * delta),
				 0, max_mana)
	stamina = clamp(stamina + (stamina_per_second * delta),
					0, max_stamina)


func cast_spell_if_pressed(delta):
	if selected_spell == null:
		return
	if not Input.is_action_pressed("cast_spell") and beam != null:
		beam.queue_free()
		beam = null
		return
	if Input.is_action_pressed("cast_spell") and beam != null:
		mana -= clamp(beam.MANA_COST*delta, 0, max_mana)
		if mana <= 0:
			beam.queue_free()
			beam = null
			return
		
	if not Input.is_action_just_pressed("cast_spell"): return
	
	var spell = selected_spell.instance()
	
	spell.try_cast(self)


func set_animation():
	if velocity.y > 0: 
		$PlayerSprite.play("down")
	if velocity.y < 0: 
		$PlayerSprite.play("up")
		
	if velocity.y != 0: return
	
	if velocity.x > 0: 
		$PlayerSprite.play("right")
	if velocity.x < 0: 
		$PlayerSprite.play("left")


func _on_PickupArea_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if held_big_item != null: return
	
	var obj = body.get_parent()
	if not obj.Pickupable: return
	
	held_big_item = obj
