extends "res://Scripts/BaseScripts/Boss.gd"


export var LAP_SPEED = 200
export var DASH_SPEED = 300
export var AREAATTACK_SPEED = 800
export var DASH_OVERSHOOT_MULTI = 50
export var DASH_COOLDOWN = 0.5
export var DAMAGE = 5
export var DISTANCE_TO_LAP = 150
export var LAP_COMPLETED_COMFORT_ZONE = 10
export var LAPS_TO_MAKE = 3
export var DASHES = 3
export var FIRE_COOLDOWN_MS = 100
export var RAYCAST_DIST: int = 100000
export var LAP_ATTACK_DELAY: float = 5

onready var AreaAttackCollider = $AreaAttackCollider.get_node("CollisionShape2D")
onready var Fire = preload("res://Enemies/Attacks/Fire.tscn")

var state
var lapsCompleted = 0
var dashesCompleted = 0
var dashingPosition
var definedAreaPoints = []
var startedArea
var lastFire
var lap_attack_counter: float = 0


enum states {
	DEFAULT,
	STILL,
	LAPPING,
	DASHING,
	WAITINGTODASH,
	AREAATTACKING,
}


func _ready():
	yield(self, "enabled")
	print("enabled")
	$AnimatedSprite.play("default")
	var _obj = $AttackCollider.connect("body_entered", self, "_on_AttackCollider_body_entered")

func on_death():
	$AnimatedSprite.scale = Vector2(1.4, 1.4)
	$AnimatedSprite.play("death")
	yield($AnimatedSprite, "animation_finished")
	emit_signal("death_finished")


func generateTargetPositions(from_pos:Vector2):
	definedAreaPoints = []
	
	var farLeftPos = Main.cast_ray_towards_point(
		from_pos, from_pos + Vector2(-10, 0),
		RAYCAST_DIST,
		0b00000000_00000000_00000000_00001000, []
	)
	var farRightPos = Main.cast_ray_towards_point(
		from_pos, from_pos + Vector2(10, 0),
		RAYCAST_DIST,
		0b00000000_00000000_00000000_00001000, []
	)
	var roomLength = farLeftPos.position.distance_to(farRightPos.position)
	var attacks = floor(roomLength/AreaAttackCollider.shape.extents.x*2)
	
	for i in range(attacks):
		var middle = farLeftPos.position + Vector2((AreaAttackCollider.shape.extents.x*2) * i+1, -(AreaAttackCollider.shape.extents.y/2))
		var top = Main.cast_ray_towards_point(
			middle, middle+Vector2(0, 10),
			RAYCAST_DIST,
			0b00000000_00000000_00000000_00001000, []
		)
		var bottom = Main.cast_ray_towards_point(
			middle, middle+Vector2(0, -10),
			RAYCAST_DIST,
			0b00000000_00000000_00000000_00001000, []
		)
		
		if len(top) <= 0 or len(bottom) <= 0:
			continue
		
		definedAreaPoints.append({
			top = top.position,
			bottom = bottom.position
		})

func _physics_process(delta):
	if not Enabled:
		return
	
	target_player = Main.get_node("Player")
	target_pos = target_player.global_position
	state = get_state()
	
	if is_sliding():
		move(target_pos, delta)
		return
	
	if !target_pos:
		return
	match state:
		states.STILL:
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.scale = Vector2.ONE
			$AnimatedSprite.play("default")
		states.DEFAULT:
			curr_speed = SPEED
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.scale = Vector2.ONE
			$AnimatedSprite.play("default")
			move(target_pos, delta)
			
			$AttackWarning.visible = false
		states.AREAATTACKING:
			if len(definedAreaPoints) <= 0:
				generateTargetPositions(target_pos)
			
			curr_speed = AREAATTACK_SPEED
			var moveToPos = definedAreaPoints[0].bottom
			var warningPos = definedAreaPoints[0].top
			var shouldFlipY = false
			if len(definedAreaPoints) % 2 == 0:
				moveToPos = definedAreaPoints[0].top
				warningPos = definedAreaPoints[0].bottom
				shouldFlipY = true
			
			$AttackWarning.global_position = warningPos
			$AttackWarning.visible = true
			
			if not startedArea:
				move(warningPos, delta)
				$AnimatedSprite.play("default")
				if global_position.distance_to(warningPos) <= LAP_COMPLETED_COMFORT_ZONE:
					startedArea = true
				return
			
			if not lastFire or (Time.get_ticks_msec() - lastFire) >= FIRE_COOLDOWN_MS:
				lastFire = Time.get_ticks_msec()
				var newFire = Fire.instance()
				newFire.global_position = global_position
				Main.add_child(newFire)
			
			$AnimatedSprite.play("area")
			$AnimatedSprite.flip_v = shouldFlipY
			move(moveToPos, delta)
			
			if global_position.distance_to(moveToPos) <= LAP_COMPLETED_COMFORT_ZONE:
				definedAreaPoints.remove(0)
				startedArea = false
				if len(definedAreaPoints) <= 0:
					state = states.DEFAULT
				return
			
			pass
		states.WAITINGTODASH:
			move(dashingPosition, delta)
			$AnimatedSprite.rotation_degrees = 0
			$AnimatedSprite.scale = Vector2.ONE
			$AnimatedSprite.play("default")
		states.DASHING:
			if !dashingPosition:
				var rayResult = Main.cast_ray_towards_point(global_position, target_pos, 500, 0b00000000_00000000_00000000_00000001, [])
				dashingPosition = target_pos + (rayResult.normal*-DASH_OVERSHOOT_MULTI)
			
			var angleToPlayer = rad2deg(global_position.angle_to_point(target_pos))
			$AnimatedSprite.rotation_degrees = -90
			if angleToPlayer < 0:
				$AnimatedSprite.rotation_degrees = 90
			$AnimatedSprite.play("dash")
			$AnimatedSprite.scale = Vector2(0.8, 0.8)
			
			
			curr_speed = DASH_SPEED
			move(dashingPosition, delta)
			
			if global_position.distance_to(dashingPosition) <= LAP_COMPLETED_COMFORT_ZONE:
				state = states.WAITINGTODASH
				yield(Main.wait(DASH_COOLDOWN), "completed")
				dashingPosition = null
				state = states.DASHING
				dashesCompleted += 1
				
				if dashesCompleted >= DASHES:
					dashesCompleted = 0
					state = states.DEFAULT
		states.LAPPING:
			lap_attack_counter = max(0, lap_attack_counter - delta)
			curr_speed = LAP_SPEED
			var targetLapPosition = target_pos+Vector2(60,-120)
			if lapsCompleted % 2 == 0:
				targetLapPosition = target_pos+Vector2(-60,-120)
			
			move(targetLapPosition, delta)
			
			if global_position.distance_to(targetLapPosition) <= LAP_COMPLETED_COMFORT_ZONE:
				lapsCompleted+=1
			
			if lapsCompleted >= LAPS_TO_MAKE or lap_attack_counter == 0:
				lapsCompleted = 0
				var selected = rand.randi_range(1,8)
				if selected % 2 == 0:
					print("Dashing")
					state = states.DASHING
					return
				print("Area attack")
				state = states.AREAATTACKING


func animation_finished():
	pass


func get_state():
	if state == states.AREAATTACKING:
		return states.AREAATTACKING
		
	if target_player == null:
		return states.DEFAULT
	
	if state == states.WAITINGTODASH:
		return states.WAITINGTODASH
	
	if state == states.DASHING:
		return states.DASHING
	
	if state == states.LAPPING:
		return states.LAPPING
	
	if state == states.STILL:
		return states.STILL
	
	if global_position.distance_to(target_player.global_position) <= DISTANCE_TO_LAP:
		lap_attack_counter = LAP_ATTACK_DELAY
		return states.LAPPING
	
	
	return states.DEFAULT


func _on_AttackCollider_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(DAMAGE)

func _on_areaattackcollider_body_entered(body):
	if len(definedAreaPoints) <= 0:
		return
	if body.is_in_group("Player"):
		body.hurt(DAMAGE)
