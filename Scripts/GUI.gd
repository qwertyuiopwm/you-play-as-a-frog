extends Control


onready var Main = get_node("/root/Main")
onready var Player = get_parent()
onready var MusicPlayer = Player.get_node("MusicPlayer")
onready var MainMenu = $MainMenu
onready var ingameUI = $IngameUI
onready var PauseMenu = $PauseMenu
onready var PlaytimeLabel = PauseMenu.get_node("playtime")
onready var ControlsContainer = PauseMenu.get_node("ScrollContainer/VBoxContainer")
onready var BaseControl = ControlsContainer.get_node("base")
onready var spellWheel = ingameUI.get_node("spellwheel")
onready var wheelComponents = spellWheel.get_node("WheelParts")
onready var wheelArrow = spellWheel.get_node("arrow")
onready var spellSpot = ingameUI.get_node("spellspot")
onready var hpDisplay = ingameUI.get_node("top_bar/stats_bg/VBoxContainer/stats/HP_Canvas/HP_bar")
onready var stamDisplay = ingameUI.get_node("top_bar/stats_bg/VBoxContainer/stats/Stamina_Canvas/stam_bar")
onready var manaDisplay = ingameUI.get_node("spellspot/mana_display")
onready var potionCount = ingameUI.get_node("potions")
onready var vp = get_viewport() 
onready var waitingForInput = false
onready var waitingInputMenu
onready var waitingInputName

var SpellWheelPositions = []
var shownkeys = {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"select_spell": "Select Spell",
	"cast_spell": "Cast Spell",
	"melee": "Melee",
	"restore": "Use Potion",
	"toggle_auto_aim": "Toggle Auto Aim"
}


func hide():
	$IngameUI/top_bar/stats_bg/VBoxContainer/stats/HP_Canvas.visible = false
	$IngameUI/top_bar/stats_bg/VBoxContainer/stats/Stamina_Canvas.visible = false
	$IngameUI/spellspot.visible = false
	
	for canvas in get_children():
		canvas.visible = false


func magnitude(vec: Vector2):
	return sqrt(pow(vec.x, 2)+pow(vec.y, 2))

func _ready():
	MainMenu.visible = true
	Main.pause(true, [Player])
		
	generateWheel()
	generateControls()
	
func onKeyClick(inputMenu, actionName):
	for action in InputMap.get_action_list("pause_game"):
		InputMap.action_erase_event("pause_game", action)
	
	inputMenu.get_node("Key").text = "Click a key to set input!"
	for action in InputMap.get_action_list(actionName):
		InputMap.action_erase_event(actionName, action)
	waitingInputMenu = inputMenu
	waitingInputName = actionName
	waitingForInput = true

func eventToString(event: InputEvent):
	var inputStr = event.as_text()
	if event is InputEventMouseButton:
		inputStr = "Mouse Button %s" % event.button_index
	if event is InputEventJoypadButton:
		inputStr = "Joypad Button %s" % event.button_index
	if event is InputEventJoypadMotion:
		match event.axis:
			event.JoyAxis.JOY_AXIS_LEFT_X:
				inputStr = "Left Joystick"
			event.JoyAxis.JOY_AXIS_RIGHT_X:
				inputStr = "Right Joystick"
			event.JoyAxis.JOY_AXIS_RIGHT_Y:
				inputStr = "Right Joystick"
			event.JoyAxis.JOY_AXIS_LEFT_Y:
				inputStr = "Left Joystick"
	return inputStr

func _input(event):
	if !waitingForInput:
		return
	if event is InputEventMouseMotion:
		return
	var keyButton = waitingInputMenu.get_node("Key")
	keyButton.text = "No input selected"
	if event.as_text() != "Escape":
		keyButton.text = eventToString(event)
		InputMap.action_add_event(waitingInputName, event)
	var pause_key = InputEventKey.new	()
	pause_key.scancode = KEY_ESCAPE
	InputMap.action_add_event("pause_game", pause_key)
	waitingForInput = false

func generateControls():
	for actionName in shownkeys:
		var keys = InputMap.get_action_list(actionName)
		if len(keys) <= 0:
			continue
		for action in keys:
			var inputStr = eventToString(action)
			var newInput = BaseControl.duplicate()
			newInput.get_node("Name").text = shownkeys[actionName]
			newInput.get_node("Key").text = inputStr
			newInput.name = actionName
			newInput.visible = true
			ControlsContainer.add_child(newInput)
			newInput.get_node("Key").connect("pressed", self, "onKeyClick", [newInput, actionName])


func generateWheel():
	var spellSlots = len(Player.PlayerSpells)
	for child in wheelComponents.get_children():
		child.queue_free()
	var positions = []
	
	var wheel = spellWheel.get_node("wheel_bg")
	var baseLine = spellWheel.get_node("line_base")
	var baseIcon = spellWheel.get_node("icon_base")
	var wheelRadius = wheel.rect_size.x / 2
	var distanceFromCenter = 0.65
	var sectorAngle: float = (360.0 / spellSlots)
	var spellCount = len(Player.PlayerSpells)
	
	var i = 0
	for packedSpell in Player.PlayerSpells:
		i+=1
		# Temporarily load spell into memory
		var spell = packedSpell.instance()
		var lineAngle = sectorAngle * i
		
		# Generate seperator line
		if spellCount > 1:
			var newLine = baseLine.duplicate()
			newLine.rect_rotation = lineAngle
			newLine.visible = true
			wheelComponents.add_child(newLine)
		# Generate spell icon
		# MAAAATTHHHHHHH RAAAAAAHHHHHHHHHH
		var newIcon = baseIcon.duplicate()
		var iconPosition = (Vector2(-distanceFromCenter, 0) * wheelRadius)
		iconPosition = iconPosition.rotated(deg2rad(lineAngle - (sectorAngle/2)))
		iconPosition -= Vector2(newIcon.rect_size.x/2, newIcon.rect_size.y/2)
		
		newIcon.rect_position = iconPosition
		newIcon.visible = true
		newIcon.name = spell.name + "Icon"
		newIcon.texture = load(spell.SpellIcon)
		
		wheelComponents.add_child(newIcon)
		positions.push_back(iconPosition)
		
		# Remove temporary spell from memory
		spell.queue_free()
		
	SpellWheelPositions = positions


func _process(_delta):
	if waitingForInput:
		return
	if Input.is_action_just_pressed("pause_game") and !MainMenu.visible:
		PlaytimeLabel.text = "Playtime: %s" % Main.time_convert(Main.PlaytimeSeconds)
		PauseMenu.visible = not Main.Paused
		Main.pause(not Main.Paused, [])
	hpDisplay.max_value = Player.max_health
	hpDisplay.value = Player.health
	
	stamDisplay.max_value = Player.max_stamina
	stamDisplay.value = Player.stamina
	
	manaDisplay.max_value = Player.max_mana
	manaDisplay.value = Player.mana
	
	$IngameUI/autoaim.visible = Player.auto_aim_enabled
	
	potionCount.text = String(Player.restoration_postions)+"x"
	
	spellWheel.visible = Input.is_action_pressed("select_spell")
	
	if spellWheel.visible:
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
		var selectedSpell = Player.PlayerSpells[(selectedIndex-1)]
		if selectedSpell:
			Player.selected_spell = selectedSpell
			
			var iconPos = SpellWheelPositions[selectedIndex-1] + Vector2(16,16)
			var mouseAngle = rad2deg(iconPos.angle())
			wheelArrow.rect_rotation = mouseAngle + 180#round(mouseAngle / degPerSpell) * degPerSpell + 180
	
	if Input.is_action_just_released("select_spell"):
		spellSpot.get_node("spellicon").texture = load(Player.selected_spell.instance().SpellIcon)


func _on_Button_pressed():
	MainMenu.visible = false
	MusicPlayer.PlaySong("ForestMusic")
	Main.pause(false, [])
