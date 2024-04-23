extends "res://Scripts/BaseScripts/Triggerable.gd"

export var BackgroundColor: Color
export var TopText: String
export var TopColor: Color
export var BottomText: String
export var BottomColor: Color
export var DisplayLengthSeconds: float = 3
export var TweenLengthSeconds: float = .75
export var SetPlayerPosition: NodePath # Set to 0,0 to keep current position
export var CreateSavePoint: bool

onready var PlayerNode = Main.get_node("Player")
onready var SaveSys = Main.get_node("Save")
onready var GUI = PlayerNode.get_node("GUI")
onready var TransitionTween = get_node("Tween")
onready var TransparencyHolder = get_node("TransparencyHolder")
onready var TransferContainer:CanvasLayer = GUI.get_node("LevelTransition")
onready var Background:Panel = TransferContainer.get_node("bg")
onready var TopLabel:Label = TransferContainer.get_node("TopText")
onready var BottomLabel:Label = TransferContainer.get_node("BottomText")

var running = false

func save():
	if not CreateSavePoint:
		return
	var savedPosition = PlayerNode.global_position
	if SetPlayerPosition:
		savedPosition = get_node(SetPlayerPosition).position
	
	SaveSys.save()
	

func onTriggerAny(_trigger):
	running = true
	TopLabel.text = TopText
	BottomLabel.text = BottomText
	TransitionTween.interpolate_property(TransparencyHolder, "position", 
		Vector2(0,0), Vector2(1, 1),
		TweenLengthSeconds,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	
	# Pause game
	Main.pause(true, [])
	TransferContainer.visible = true
	TransitionTween.start()
	yield(Main.wait(DisplayLengthSeconds+TweenLengthSeconds), "completed")
	TransitionTween.interpolate_property(TransparencyHolder, "position", 
		Vector2(1,0), Vector2(0, 0),
		TweenLengthSeconds,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	if SetPlayerPosition:
		PlayerNode.global_position = get_node(SetPlayerPosition).global_position
	# Unpause game
	TransitionTween.start()
	yield(Main.wait(TweenLengthSeconds), "completed")
	if CreateSavePoint: 
		save()
		print("Saved")
	Main.pause(false, [])
	TransferContainer.visible = false
	running = false
	
func _physics_process(_delta):
	if not running:
		return
	var newBGColor = BackgroundColor
	var newTopColor = TopColor
	var newBottomColor = BottomColor
	newBGColor.a*=TransparencyHolder.position.x
	newTopColor.a*=TransparencyHolder.position.x
	newBottomColor.a*=TransparencyHolder.position.x
	
	Background.modulate = newBGColor
	TopLabel.add_color_override("font_color", newTopColor)
	BottomLabel.add_color_override("font_color", newBottomColor)
	
