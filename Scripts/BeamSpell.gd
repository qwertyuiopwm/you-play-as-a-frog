extends "res://Scripts/Spell.gd"


export var TYPE = "BEAM"
export var MANA_REQUIRED = 15 # Initial mana cost

onready var beamLine:Line2D = get_node("Line2D")
onready var Main = get_node("/root/Main")

func on_start():
	pass


func on_process():
	pass


func on_settle():
	pass


func hit(body, delta):
	if not body is Entity:
		return
	hurt(body, DAMAGE * delta)


func _ready():
	on_start()


func _physics_process(delta):
	var rootPos = Player.global_position
	var mousePos = get_global_mouse_position()
	var targetPos = rootPos + (rootPos.direction_to(mousePos)*900)
	
	var rayResult = Main.cast_ray(rootPos, targetPos, 0b00000000_00000000_00000001_00001000, [])

	if not rayResult.has("position"):
		return
	if rayResult.collider:
		hit(rayResult.collider, delta)
	
	beamLine.points[0] = to_local(rootPos)
	beamLine.points[1] = to_local(rayResult.position)

func _process(_delta):
	on_process()


func try_cast(player):
	if player.mana < MANA_REQUIRED: 
		queue_free()
		return
	player.mana -= MANA_REQUIRED
	
	player.get_parent().add_child(self)
	player.beam = self
