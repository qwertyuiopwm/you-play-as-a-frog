extends Control


onready var Main = get_node("/root/Main")
onready var Player = get_parent()
onready var MusicPlayer = Player.get_node("MusicPlayer")
onready var MainMenu = $MainMenu
onready var ingameUI = $IngameUI
onready var spellWheel = ingameUI.get_node("spellwheel")
onready var wheelArrow = spellWheel.get_node("arrow")
onready var spellSpot = ingameUI.get_node("spellspot")
onready var hpDisplay = ingameUI.get_node("top_bar/stats_bg/VBoxContainer/stats/HP_Canvas/HP_bar")
onready var stamDisplay = ingameUI.get_node("top_bar/stats_bg/VBoxContainer/stats/Stamina_Canvas/stam_bar")
onready var manaDisplay = ingameUI.get_node("spellspot/mana_display")
onready var vp = get_viewport() 

var SpellWheelPositions = []

func magnitude(vec: Vector2):
	return sqrt(pow(vec.x, 2)+pow(vec.y, 2))

func _ready():
	MainMenu.visible = true
	for node in Main.get_children():
		if node == Player:
			continue
		node.get_tree().paused = true
		
	
	SpellWheelPositions = generateWheel(len(Player.spells))
	var i = 0
	for packedSpell in Player.spells:
		i+=1
		var spell = packedSpell.instance()
		var spellIcon:TextureRect =  ingameUI.get_node("spellwheel/Spell"+String(i)+"Icon")
		spellIcon.texture = load(spell.SpellIcon)
		

func generateWheel(spellSlots: int):
	var positions = []
	#if spellSlots <= 1:
	#	positions.push_back(Vector2(0,0))
	#	return positions
	
	var wheel = spellWheel.get_node("wheel_bg")
	var baseLine = spellWheel.get_node("line_base")
	var baseIcon = spellWheel.get_node("icon_base")
	var wheelRadius = wheel.rect_size.x / 2
	var distanceFromCenter = 0.65
	var sectorAngle = (360 / spellSlots)
	
	for i in spellSlots:
		# Generate seperator line
		var newLine = baseLine.duplicate()
		var lineAngle = sectorAngle * i
		newLine.rect_rotation = lineAngle
		newLine.visible = true
		spellWheel.add_child(newLine)
		# Generate spell icon
		# MAAAATTHHHHHHH RAAAAAAHHHHHHHHHH
		var newIcon = baseIcon.duplicate()
		var iconPosition = (Vector2(-distanceFromCenter, 0) * wheelRadius)
		iconPosition = iconPosition.rotated(deg2rad(lineAngle - (sectorAngle/2)))
		iconPosition -= Vector2(newIcon.rect_size.x/2, newIcon.rect_size.y/2)
		
		newIcon.rect_position = iconPosition
		newIcon.visible = true
		newIcon.name = "Spell" + String(i + 1) + "Icon"
		
		spellWheel.add_child(newIcon)
		positions.push_back(iconPosition)
	return positions


func _process(delta):
	hpDisplay.max_value = Player.max_health
	hpDisplay.value = Player.health
	
	stamDisplay.max_value = Player.max_stamina
	stamDisplay.value = Player.stamina
	
	manaDisplay.max_value = Player.max_mana
	manaDisplay.value = Player.mana
	
	spellWheel.visible = Input.is_action_pressed("select_spell")
	
	if spellWheel.visible:
		var degPerSpell = 360/len(Player.spells)
		var mousePos = vp.get_mouse_position()
		var lowestMag = INF
		var selectedIndex: int
		var i = 0
		for vector in SpellWheelPositions:
			i+=1
			var newMag = magnitude(vector+Vector2(400,400)-mousePos)
			if newMag < lowestMag:
				selectedIndex = i
				lowestMag = newMag
		var selectedSpell = Player.spells[(selectedIndex-1)]
		if selectedSpell:
			Player.selected_spell = selectedSpell
			
			var _mousePos = mousePos - Vector2(400,400)
			var mouseAngle = rad2deg(_mousePos.angle())
			wheelArrow.rect_rotation = mouseAngle + 180#round(mouseAngle / degPerSpell) * degPerSpell + 180
			
			spellSpot.get_node("spellicon").texture = load(selectedSpell.instance().SpellIcon)
		


func _on_Button_pressed():
	Main.GameStarted = true
	MainMenu.visible = false
	MusicPlayer.PlaySong("ForestMusic")
	for node in Main.get_children():
		if node == Player:
			continue
		node.get_tree().paused = false
