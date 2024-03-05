extends CanvasLayer


onready var Player = get_parent().get_parent()
onready var Main = Player.get_parent()
onready var devTools = self
onready var bg = devTools.get_node("bg")
onready var devToolsLabels = devTools.get_node("HBoxContainer/Labels")
onready var devToolsValues = devTools.get_node("HBoxContainer/Values")

onready var enemies = {
	Ant = preload("res://Enemies/Ant.tscn"),
	Fly = preload("res://Enemies/Fly.tscn"),
	Grub = preload("res://Enemies/Grub.tscn"),
	Weevil = preload("res://Enemies/Weevil.tscn"),
}

var selectedEnemy:PackedScene

func _ready():
	var EnemyDropdown:OptionButton = devToolsValues.get_node("EnemyOption")
	var i = 1
	for name in enemies:
		
		EnemyDropdown.add_item(name, i)
		i+=1

func _input(event):
	if not event is InputEventMouseButton:
		return
	if selectedEnemy == null:
		return
	var EnemyOption = devToolsValues.get_node("EnemyOption")
	if EnemyOption.get_focus_owner() != null:
		EnemyOption.release_focus()
		return
	
	var newEnemy = selectedEnemy.instance()
	Main.add_child(newEnemy)
	newEnemy.global_position = Main.get_global_mouse_position()
	selectedEnemy = null

func _on_EnemyOption_item_selected(index: int):
	var EnemyOption = devToolsValues.get_node("EnemyOption")
	selectedEnemy = enemies.get(EnemyOption.text)

func _process(_delta):
	if Input.is_action_just_pressed("toggle_devtools"):
		devTools.visible = not devTools.visible
	
	var healthText = devToolsValues.get_node("HealthText")
	var maxHealthText = devToolsValues.get_node("MaxHealthText")
	var speedText = devToolsValues.get_node("SpeedText")
	var godmodeCheckbox = devToolsValues.get_node("GodmodeCheckbox")
	var noclipCheckbox = devToolsValues.get_node("NoclipCheckbox")
	
	if healthText.get_focus_owner() == null:
		healthText.text = String(Player.health)
	else:
		Player.health = float(healthText.text)
	
	if maxHealthText.get_focus_owner() == null:
		maxHealthText.text = String(Player.max_health)
	else:
		Player.max_health = float(maxHealthText.text)
	
	if noclipCheckbox.pressed:
		Player.collision_layer = 0b00000000_00000000_00000000_00000000
		Player.collision_mask = 0b00000000_00000000_00000000_00000000
	else:
		Player.collision_layer = 0b00000000_00000000_00000000_00000001
		Player.collision_mask = 0b00000000_00000000_00000000_00000001
	
	Player.SPEED = float(speedText.text)
	Player.god_enabled = godmodeCheckbox.pressed
	
func _is_pos_in(checkpos:Vector2):
	if Rect2(Vector2(), bg.rect_size).has_point(checkpos):
		return true
	return false
