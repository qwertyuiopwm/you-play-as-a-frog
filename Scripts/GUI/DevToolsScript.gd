extends CanvasLayer


onready var Player = get_parent().get_parent()
onready var GUI = Player.get_node("GUI")
onready var Main = Player.get_parent()
onready var devTools = self
onready var bg = devTools.get_node("bg")
onready var devToolsLabels = devTools.get_node("HBoxContainer/Labels")
onready var devToolsValues = devTools.get_node("HBoxContainer/Values")

onready var enemies = {
	Ant = preload("res://Enemies/Forest/Ant.tscn"),
	Fly = preload("res://Enemies/Forest/Fly.tscn"),
	Grub = preload("res://Enemies/Forest/Grub.tscn"),
	Weevil = preload("res://Enemies/Forest/Weevil.tscn"),
	StagBeetle = preload("res://Enemies/Swamp/StagBeetle.tscn"),
	Mosquito = preload("res://Enemies/Swamp/Mosquito.tscn"),
	Centipede = preload("res://Enemies/Forest/Centipede/CentipedeHead.tscn"),
	Strider = preload("res://Enemies/Swamp/Strider.tscn"),
	Dummy = preload("res://Enemies/Extras/Dummy.tscn"),
	Scorpion = preload("res://Enemies/Swamp/Scorpion.tscn"),
	CobaltBeetle = preload("res://Enemies/CaveCrypt/CobaltBeetle.tscn"),
}

var selectedEnemy: PackedScene

func _ready():
	var EnemyDropdown: OptionButton = devToolsValues.get_node("EnemyOption")
	var _enemyConn = EnemyDropdown.connect("item_selected", self, "_on_EnemyOption_item_selected")
	var i = 1
	for name in enemies:
		
		EnemyDropdown.add_item(name, i)
		i+=1
	
	var SpellDropdown: OptionButton = devToolsValues.get_node("SpellOption")
	var _spellConn = SpellDropdown.connect("item_selected", self, "_on_SpellOption_item_selected")
	var i2 = 1
	for name in Spells.AllSpells:
		SpellDropdown.add_item(name, i2)
		i2+=1

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

func _on_EnemyOption_item_selected(_index: int):
	var EnemyOption = devToolsValues.get_node("EnemyOption")
	selectedEnemy = enemies.get(EnemyOption.text)

func _on_SpellOption_item_selected(_index: int):
	var SpellOption = devToolsValues.get_node("SpellOption")
	Player.PlayerSpells.append(Spells.AllSpells.get(SpellOption.text))
	GUI.generateWheel()
	SpellOption.release_focus()

func _process(_delta):
	if Input.is_action_just_pressed("toggle_devtools"):
		devTools.visible = not devTools.visible
	
	var healthText = devToolsValues.get_node("HealthText")
	var maxHealthText = devToolsValues.get_node("MaxHealthText")
	var speedText = devToolsValues.get_node("SpeedText")
	var damageMultText = devToolsValues.get_node("DamageText")
	var godmodeCheckbox = devToolsValues.get_node("GodmodeCheckbox")
	var noclipCheckbox = devToolsValues.get_node("NoclipCheckbox")
	
	if healthText.get_focus_owner() == null or not devTools.visible:
		healthText.text = String(Player.health)
	else:
		Player.health = float(healthText.text)
	
	if maxHealthText.get_focus_owner() == null or not devTools.visible:
		maxHealthText.text = String(Player.max_health)
	else:
		Player.max_health = float(maxHealthText.text)
	
	if damageMultText.get_focus_owner() == null or not devTools.visible:
		damageMultText.text = String(Player.damage_mult)
	else:
		Player.damage_mult = float(damageMultText.text)
	
	if noclipCheckbox.pressed:
		Player.collision_layer = 0b00000000_00000000_00000000_00000000
		Player.collision_mask = 0b00000000_00000000_00000000_00000000
	else:
		Player.collision_layer = 0b00000000_00000000_00000000_00000001
		Player.collision_mask = 0b00000000_00000000_00000000_00000001
	
	if speedText.get_focus_owner() == null or not devTools.visible:
		speedText.text = String(Player.SPEED)
	else:
		Player.SPEED = float(speedText.text)
	
	if devTools.visible:
		Player.god_enabled = godmodeCheckbox.pressed
	godmodeCheckbox.pressed = Player.god_enabled
	
func _is_pos_in(checkpos:Vector2):
	if Rect2(Vector2(), bg.rect_size).has_point(checkpos):
		return true
	return false
