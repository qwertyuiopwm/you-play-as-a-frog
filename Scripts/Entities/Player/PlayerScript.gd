extends "res://Scripts/BaseScripts/Entity.gd"

signal death_scene_finished
signal death_scene_popup_finished

export var SPEED = 400
export var SLIP_SPEED_MULT = 1.1
export var SELF_CAST_RANGE = 20
export var HELD_ITEM_POS: Vector2
export(Array, PackedScene) var PlayerSpells = [
	Spells.Procure_Condiment,
	Spells.Dev_Beam,
]


export var selected_spell: PackedScene
export var auto_aim_enabled: bool = true
export var god_enabled: bool
export var restoration_potions: int = 0
export var health_per_potion: float = 30
export var mana_per_potion: float = 50
export var stamina_per_potion: float = 80

onready var Main = get_node("/root/Main")
onready var SaveSys = Main.get_node("Save")
onready var GUI = get_node("GUI")
onready var MusicPlayer = $MusicPlayer
onready var TongueLine = $Tongue
onready var TonguePosition = $TonguePosition
onready var TongueTween = $TongueTween
onready var PlayerSprite = $PlayerSprite

onready var screen_size = get_viewport_rect().size
onready var radius = $CollisionShape2D.shape.radius
onready var height = $CollisionShape2D.shape.height + radius * 2
onready var half_height = height / 2
onready var debug = OS.is_debug_build()

# Death scene variables
onready var TransitionTween = get_node("DeathTween")
onready var TransparencyHolder = get_node("DeathTransparencyHolder")
onready var TransferContainer:CanvasLayer = GUI.get_node("LevelTransition")
onready var Background:Panel = TransferContainer.get_node("bg")
onready var TopLabel:Label = TransferContainer.get_node("TopText")
onready var BottomLabel:Label = TransferContainer.get_node("BottomText")

var deathRunning = false

export var melee_damage: float = 5
export var damage_mult = 1

var drop_time: float = 1
var drop_dist: int = 100

var dashing = false
var dash_stamina_cost = 20
var dash_speed_mult = 2
var dash_duration = .2
var dash_counter = 0

var melee_distance = 100
var tongue_speed = 350
var melee_delay = 1
var melee_counter = 0

export var max_health: float = 100
export var health: float = 100
var regen_delay = 10
var health_per_second = 2
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
	PlayerSprite.connect("animation_finished", self, "sprite_animation_finished")
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
	death_animation()
	if Main.Paused:
		return
	if health <= 0:
		return
	
	if Input.is_action_just_pressed("toggle_auto_aim"):
		auto_aim_enabled = !auto_aim_enabled
	
	check_tile()
	
	regen_stats(delta)
	
	cast_spell_if_pressed(delta)
	
	melee_if_pressed(delta)
	
	heal_if_pressed(delta)
	
	velocity = get_velocity()
	
	if velocity.length() <= 0:
		PlayerSprite.frame = 0
		PlayerSprite.stop()
		return
	
	dash_if_pressed()
	
	set_animation()
	
	var velocity_mult = 1
	velocity_mult += (int(dashing) * dash_speed_mult)
	
	var vel = move_and_slide(velocity * velocity_mult)
	if vel.length_squared() <= .01:
		velocity = Vector2.ZERO
	
	if held_big_item != null:
		held_big_item.global_position = $ItemHolder.global_position


func death_animation():
	if not deathRunning:
		return
	var newBGColor = Color.black
	var newTopColor = Color.white
	var newBottomColor = Color.white
	newBGColor.a*=TransparencyHolder.position.x
	newTopColor.a*=TransparencyHolder.position.x
	newBottomColor.a*=TransparencyHolder.position.x
	
	Background.modulate = newBGColor
	TopLabel.add_color_override("font_color", newTopColor)
	BottomLabel.add_color_override("font_color", newBottomColor)

func death_scene():
	deathRunning = true
	TopLabel.text = "You Died!"
	BottomLabel.text = "Bottom Text" #:clueless:
	TransitionTween.interpolate_property(TransparencyHolder, "position", 
		Vector2(0,0), Vector2(1, 1),
		0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	
	# Pause game
	Main.pause(true, [])
	TransferContainer.visible = true
	TransitionTween.start()
	yield(Main.wait(2), "completed")
	emit_signal("death_scene_popup_finished")
	TransitionTween.interpolate_property(TransparencyHolder, "position", 
		Vector2(1,0), Vector2(0, 0),
		0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	
	yield(Main.wait(0.5), "completed")
	SaveSys.loadSave()
	$CollisionShape2D.disabled = false
	PlayerSprite.play("down")
	
	# Unpause game
	TransitionTween.start()
	yield(Main.wait(0.5), "completed")
	Main.pause(false, [])
	TransferContainer.visible = false
	deathRunning = false
	emit_signal("death_scene_finished")

func sprite_animation_finished():
	if PlayerSprite.animation != "death":
		return
	$CollisionShape2D.disabled = true
	
	death_scene()


func get_curr_tile():
	for tile_map in get_tree().get_nodes_in_group("ground"):
		var player_local_pos = tile_map.to_local(global_position)
		var pos = tile_map.world_to_map(player_local_pos)
		var tile_id = tile_map.get_cellv(pos)
		if tile_id >= 0:
			var tmn = tile_map.tile_set.tile_get_name(tile_id)
#			if len(tmn) <= 0:
#				print(global_position)
#				print(tile_map.get_path())
			return tmn
	return null


func check_tile():
	var curr_tile = get_curr_tile()
	if curr_tile == null:
		curr_tile = ""
	if not curr_tile: 
		pass
	
	sliding = "(slide)" in curr_tile


func hurt(dmg: float, ignore_hit_delay:=false):
	if god_enabled:
		return
	if health <= 0:
		return
	
	if not ignore_hit_delay:
		if no_hit_timer > 0:
			return
		no_hit_timer = no_hit_time
	
	regen_timer = regen_delay
	
	var newHp: float = health - dmg
	if newHp <= 0:
		PlayerSprite.play("death")
		pass
	
	MusicPlayer.PlayOnNode("Playerhurt", self)
	health = newHp


func Heal(hp: float):
	if health <= 0:
		return
		
	var newHp = health + hp
	if newHp > max_health:
		newHp = max_health
	
	health = newHp


func drop_big_item(dropAngle: int = -1):
	if not held_big_item:
		return
	
	dropAngle %= 360
	if dropAngle == -1:
		dropAngle = int(rand_range(0, 360))
	
	var item = held_big_item
	
	var itemPos = item.global_position
	var targetPos = global_position + Vector2(0, 1).rotated(deg2rad(-dropAngle)) * drop_dist
	
	item.Pickupable = false
	item.set_pickupable(drop_time + .5)
	
	held_big_item = null
	remove_child(item)
	Main.add_child(item)
	
	item.global_position = itemPos
	
	$DropTween.interpolate_property(item, "global_position", 
		item.global_position, 
		targetPos, 
		drop_time, Tween.TRANS_CUBIC, Tween.EASE_OUT
	)
	$DropTween.start()


func AddSpell(spell):
	if not Spells.AllSpells.has(spell):
		print("Couldn't add spell '", spell, "'")
		return
	
	var spell_scene = Spells.AllSpells[spell]
	
	if PlayerSpells.has(spell_scene):
		print("Player already has '", spell, "', skipping adding spell")
		return
	
	PlayerSpells.push_back(spell_scene)
	get_node("GUI").generateWheel()


func RemoveSpell(spell):
	if not Spells.AllSpells.has(spell):
		print("Couldn't remove spell '", spell, "'")
		return
	
	var spell_scene = Spells.AllSpells[spell]
	
	if not PlayerSpells.has(spell_scene):
		print("Player doesn't have '", spell, "', can't remove spell!")
		return
	
	
	PlayerSpells.erase(spell_scene)
	get_node("GUI").generateWheel()


func get_velocity():
	if not can_move:
		return Vector2.ZERO
	
	var vel = Vector2.ZERO
	
	if is_sliding() and velocity.length_squared() != 0:
		var slide_vel = Vector2.ZERO
		
		if velocity.x:
			slide_vel.x = velocity.x
		else:
			slide_vel.y = velocity.y
		
		print(slide_vel)
		return slide_vel.normalized() * SPEED * SLIP_SPEED_MULT
	
	if dashing:
		return velocity
		
	if currentFocus != null: return velocity
	
	vel.y = int(Input.is_action_pressed("move_down")) - \
				 int(Input.is_action_pressed("move_up"))
	vel.x = .9 * int(Input.is_action_pressed("move_right")) - \
				 int(Input.is_action_pressed("move_left"))
	
	vel = vel.normalized() * SPEED * slowness_mult
	
	return vel


func regen_stats(delta):
	no_hit_timer = max(no_hit_timer - delta, 0)
	
	melee_counter = max(melee_counter - delta, 0)
	
	dash_counter = max(dash_counter - delta, 0)
	if dash_counter == 0:
		dashing = false
	
	regen_timer = max(regen_timer - delta, 0)
	if regen_timer == 0:
		Heal(health_per_second * delta)
	
	if beam == null:
		mana = min(mana + (mana_per_second * delta), max_mana)
	
	stamina = min(stamina + (stamina_per_second * delta), max_stamina)


func heal_if_pressed(_delta):
	if restoration_potions <= 0:
		return
		
	if not Input.is_action_just_pressed("restore"):
		return
		
	regen_timer = 0
	Heal(health_per_potion)
	mana += mana_per_potion
	stamina += stamina_per_potion
	restoration_potions -= 1

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
	
	if global_position.distance_to(get_global_mouse_position()) <= SELF_CAST_RANGE \
	   and spell.CAN_SELF_CAST:
		spell.try_self_cast(self)
	else:
		spell.try_cast(self)


func melee_if_pressed(_delta):
	TongueLine.points[1] = TonguePosition.position
	
	if melee_counter > 0:
		return
	
	if not Input.is_action_just_pressed("melee"):
		return
	
	melee_counter = melee_delay
	
	var rootPos = TongueLine.global_position
	
	var target = get_nearest_enemy()
	if not target:
		target = $Mouse
	
	var targetPos = rootPos + (rootPos.direction_to(target.global_position)*melee_distance)
	
	var rayResult = Main.cast_ray(rootPos, targetPos, 0b00000000_00000000_00000001_00001000, [])
	
	var hitPos = targetPos
	if rayResult.has("collider"):
		var hit:Node2D = rayResult.collider
		if hit.is_in_group("Enemy"):
			hitPos = hit.get_node("CollisionShape2D").global_position
		else:
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
	# yield(TongueTween, "tween_completed")
	if rayResult.has("collider"):
		var collider = rayResult.collider
		if collider.has_method("hurt"):
			collider.hurt(melee_damage*damage_mult)


func dash_if_pressed():
	if dashing == true:
		return
	
	if not Input.is_action_just_pressed("dash"):
		return
	
	if stamina < dash_stamina_cost:
		return
	
	dash_counter = dash_duration
	dashing = true
	stamina -= dash_stamina_cost


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
	var obj = body.get_parent()
	
	if not obj.Pickupable: return
	
	obj.on_pickup(self)
	
	if obj.Type == 1:
		obj.queue_free()
		return
	
	if held_big_item != null:
		return
	
	obj.get_parent().remove_child(obj)
	call_deferred("add_child", obj)
	
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


func get_nearest_enemy(blocked_effects = [], blocked_immunities = []):
	var enemies = get_targetable_enemies()
	var nearest_enemy
	var lowest_dist = INF
	
	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist >= lowest_dist:
			continue
		
#		if !target_in_sight(enemy):
#			continue
		
		if enemy.has_effect(blocked_effects):
			continue
		
		if enemy.has_immunity(blocked_immunities):
			continue
		
		nearest_enemy = enemy
		lowest_dist = dist
	
	return nearest_enemy


func get_targetable_enemies():
	var colliding_target_bodies = $TargetArea.get_overlapping_bodies()
	var enemies = []
	for body in colliding_target_bodies:
		if body.is_in_group("Enemy"):
			enemies.push_back(body)
	return enemies


func get_target(blocked_effects = [], blocked_immunities = []):
	var target = get_nearest_enemy(blocked_effects, blocked_immunities)
	if not target:
		target = $Mouse
	
	return target
