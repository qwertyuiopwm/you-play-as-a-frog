extends "res://Scripts/Entity.gd"


export var SPEED = 400
export var HELD_ITEM_POS: Vector2
export(Array, PackedScene) var PlayerSpells = [
	Spells.Procure_Condiment,
	Spells.Dev_Beam,
]

export var selected_spell: PackedScene
export var god_enabled: bool

onready var Main = get_node("/root/Main")
onready var MusicPlayer = $MusicPlayer
onready var TongueLine = $Tongue
onready var TonguePosition = $TonguePosition
onready var TongueTween = $TongueTween
onready var PlayerSprite = $PlayerSprite
onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2

export var melee_damage: float = 5
export var damage_mult = 1

var melee_distance = 100
var tongue_speed = 350
var melee_delay = 2
var melee_counter = 0

export var max_health: float = 100
export var health: float = 100
var regen_delay = 10
var health_per_second = 1
var regen_timer = 0
var no_hit_time = .25
var no_hit_timer = 0

var max_mana = 100
var mana = max_mana
var mana_per_second = 7
var beam: RigidBody2D

var max_stamina = 100
var stamina = max_stamina
var stamina_per_second = 10

var velocity = Vector2.ZERO

var currentFocus: Control

var held_big_item: Node2D


func _ready():
	var _obj = get_viewport().connect("gui_focus_changed", self, "_on_focus_changed")

func _remove_focus():
	currentFocus.disconnect("focus_exited", self, "_remove_focus")
	currentFocus = null

func _on_focus_changed(node):
	if node == null:
		return
	currentFocus = node
	var _obj = currentFocus.connect("focus_exited", self, "_remove_focus")

func _physics_process(delta):
	if not Main.GameStarted:
		return
	if health <= 0:
		return
	
	check_tile()
	
	regen_stats(delta)
	
	cast_spell_if_pressed(delta)
	
	melee_if_pressed(delta)
	
	velocity = get_velocity()
	
	if velocity.length() <= 0:
		PlayerSprite.frame = 0
		PlayerSprite.stop()
		return
	
	set_animation()
	var _v = move_and_slide(velocity)
	
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
	return null


func check_tile():
	var curr_tile = get_curr_tile()
	if curr_tile == null: return
	
	if "(slide)" in curr_tile:
		Afflict(Effects.slippy, 0.1)


func Hurt(dmg: float):
	if god_enabled:
		return
	if health <= 0:
		return
	if no_hit_timer > 0:
		return
	
	no_hit_timer = no_hit_time
	
	regen_timer = regen_delay
	
	var newHp = health - dmg
	if newHp <= 0:
		PlayerSprite.visible = false
		$DEATH.visible = true
		$DEATH.play("explosion")
		pass
	
	MusicPlayer.PlayOnNode("PlayerHurt", self)
	health = newHp


func Heal(hp: float):
	if health <= 0:
		return
	var newHp = health + hp
	if newHp > max_health:
		newHp = max_health
	
	health = newHp


func get_velocity():
	if not can_move:
		return Vector2.ZERO
	
	var vel = Vector2.ZERO
	if (sliding or $EffectManager.has_effect(Effects.slippy)) and \
	   velocity.length_squared() != 0: 
		return velocity
	if currentFocus != null: return velocity
	
	vel.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	vel.x = int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	vel = vel.normalized() * SPEED
	
	return vel


func regen_stats(delta):
	no_hit_timer = max(no_hit_timer - delta, 0)
	
	melee_counter = max(melee_counter - delta, 0)
	
	regen_timer = max(regen_timer - delta, 0)
	if regen_timer == 0:
		Heal(health_per_second * delta)
	
	if beam == null:
		mana = clamp(mana + (mana_per_second * delta),
				 0, max_mana)
	
	stamina = clamp(stamina + (stamina_per_second * delta),
					0, max_stamina)


func cast_spell_if_pressed(delta):
	if selected_spell == null:
		return
	if beam != null and Input.is_action_pressed("select_spell"):
		beam.queue_free()
		beam = null
		return
	if Input.is_action_pressed("select_spell"):
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


func melee_if_pressed(_delta):
	TongueLine.points[1] = TonguePosition.position
	
	if melee_counter > 0:
		return
	
	if not Input.is_action_just_pressed("melee"):
		return
	
	var rootPos = TongueLine.global_position
	var mousePos = get_global_mouse_position()
	var targetPos = rootPos + (rootPos.direction_to(mousePos)*melee_distance)
	
	var rayResult = Main.cast_ray(rootPos, targetPos, 0b00000000_00000000_00000001_00001000, [])
	
	var hitPos = targetPos
	if rayResult.has("position"):
		hitPos = rayResult.position
	var localHitPos = TongueLine.to_local(hitPos)
	
	var angleToHit = abs(rad2deg(rootPos.angle_to_point(hitPos)))
	if angleToHit >= 90:
		TongueLine.points[0] = Vector2(8, 0)
		PlayerSprite.play("right")
	else:
		TongueLine.points[0] = Vector2(-8, 0)
		PlayerSprite.play("left")
		
	var tweenTime = (Vector2.ZERO.distance_to(localHitPos)/tongue_speed)
	
	TongueTween.interpolate_property(TonguePosition, "position", 
		Vector2.ZERO, 
		localHitPos, 
		tweenTime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	TongueTween.start()


func set_animation():
	if velocity.y > 0: 
		PlayerSprite.play("down")
	if velocity.y < 0: 
		PlayerSprite.play("up")
		
	if velocity.y != 0: return
	
	if velocity.x > 0: 
		PlayerSprite.play("right")
	if velocity.x < 0: 
		PlayerSprite.play("left")


func _on_PickupArea_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if held_big_item != null: return
	
	var obj = body.get_parent()
	if not obj.Pickupable: return
	
	held_big_item = obj


func _on_TongueTween_tween_completed(object, _key):
	if object.position == Vector2.ZERO:
		TongueLine.points[0] = Vector2.ZERO
		return
		
	# Return tongue back to player
	var tweenTime = (object.position.distance_to(Vector2.ZERO)/tongue_speed)
	TongueTween.interpolate_property(TonguePosition, "position", 
		object.position, 
		Vector2.ZERO, 
		tweenTime, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	TongueTween.start()
	
	# Damage enemy if exists
	var rayResult = Main.cast_ray(
		TongueLine.to_global(Vector2.ZERO), 
		TongueLine.to_global(TongueLine.points[1]), 
		0b00000000_00000000_00000001_00000000, []
	)
	
	if rayResult.has("collider"):
		rayResult.collider.hurt(melee_damage*damage_mult)
