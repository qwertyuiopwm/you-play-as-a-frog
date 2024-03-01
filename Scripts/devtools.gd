extends CanvasLayer


onready var Player = get_parent().get_parent()
onready var devTools = self
onready var devToolsLabels = devTools.get_node("HBoxContainer/Labels")
onready var devToolsValues = devTools.get_node("HBoxContainer/Values")

func _ready():
	var EnemyDropdown:OptionButton = devToolsValues.get_node("EnemyOption")
	
	var dir = Directory.new()
	if dir.open("res://Enemies") == OK:
		dir.list_dir_begin(true, true)
		var fn = dir.get_next()
		var i = 1;
		while fn != "":
			EnemyDropdown.add_item(fn.trim_suffix(".tscn"), i)
			fn = dir.get_next()

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
	
