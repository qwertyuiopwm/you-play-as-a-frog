extends Control

onready var spellWheel = $CanvasLayer/spellwheel
onready var hpPanel = $CanvasLayer/top_bar/stats_bg/VBoxContainer/stats/HP_Canvas/Panel
onready var Player = get_parent()
onready var vp = get_viewport()
onready var maxHpSize = hpPanel.rect_size.x

var SpellWheelPositions = []

func magnitude(vec: Vector2):
	return sqrt(pow(vec.x, 2)+pow(vec.y, 2))

func _ready():
	for node in spellWheel.get_children():
		if node.get_class() != "Position2D":
			continue
		if node.name.find("Spell") == -1:
			continue
		SpellWheelPositions.push_back(node)
	var i = 0
	for packedSpell in Player.spells:
		i+=1
		var spell = packedSpell.instance()
		var spellIcon:TextureRect = get_node("CanvasLayer/spellwheel/Spell"+String(i)+"Icon")
		spellIcon.texture = load(spell.SpellIcon)
		

func _process(_delta):
	var newHealthX = (maxHpSize/Player.max_health)*Player.health
	var newRectSize = Vector2(newHealthX, 16)
	hpPanel.set_size(newRectSize)
	
	spellWheel.visible = Input.is_action_pressed("select_spell")
	
	if spellWheel.visible:
		var mousePos = vp.get_mouse_position()
		var selectedNode
		var lowestMag = INF
		for node in SpellWheelPositions:
			var newMag = magnitude(node.global_position+Vector2(400,400)-mousePos)
			if newMag < lowestMag:
				selectedNode = node
				lowestMag = newMag
		var selectedSpell = Player.spells[selectedNode.SpellIndex]
		if selectedSpell:
			Player.selected_spell = selectedSpell
			$CanvasLayer/spellwheel/arow.rect_rotation = selectedNode.ArrowRotation
		
