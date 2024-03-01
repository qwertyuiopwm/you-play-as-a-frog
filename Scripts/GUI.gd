extends Control


onready var spellWheel = $CanvasLayer/spellwheel
onready var wheelArrow = spellWheel.get_node("arrow")
onready var hpPanel = $CanvasLayer/top_bar/stats_bg/VBoxContainer/stats/HP_Canvas/Panel
onready var spellSpot = $CanvasLayer/spellspot
onready var manaPanel = spellSpot.get_node("mana")
onready var Player = get_parent()
onready var vp = get_viewport() 
onready var maxHpSize = hpPanel.rect_size.x
onready var maxManaSize = manaPanel.rect_size.x

var SpellWheelPositions = []

func magnitude(vec: Vector2):
	return sqrt(pow(vec.x, 2)+pow(vec.y, 2))

func _ready():
	SpellWheelPositions = generateWheel(len(Player.spells))
	var i = 0
	for packedSpell in Player.spells:
		i+=1
		var spell = packedSpell.instance()
		var spellIcon:TextureRect = get_node("CanvasLayer/spellwheel/Spell"+String(i)+"Icon")
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
		var iconX = (cos(deg2rad(lineAngle+sectorAngle/2)) * wheelRadius * distanceFromCenter) - (newIcon.rect_size.x/2)
		var iconY = (sin(deg2rad(lineAngle+sectorAngle/2)) * wheelRadius * distanceFromCenter) - (newIcon.rect_size.y/2)
		var iconPosition = Vector2(iconX, iconY)
		
		newIcon.rect_position = iconPosition
		newIcon.visible = true
		newIcon.name = "Spell" + String(i + 1) + "Icon"
		
		spellWheel.add_child(newIcon)
		positions.push_back(iconPosition)
	return positions


func _process(delta):
	
	var newHealthX = (maxHpSize/(100 if Player.max_health <= 0 else Player.max_health))*Player.health
	var newHpRectSize = Vector2(newHealthX, hpPanel.rect_size.y)
	hpPanel.set_size(newHpRectSize)
	
	var newManaX = (maxManaSize/Player.max_mana)*Player.mana
	var newManaRectSize = Vector2(newManaX, manaPanel.rect_size.y)
	manaPanel.set_size(newManaRectSize)
	
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
			
			wheelArrow.rect_rotation = degPerSpell*(selectedIndex+0)+(degPerSpell/2)
			spellSpot.get_node("spellicon").texture = load(selectedSpell.instance().SpellIcon)
		
