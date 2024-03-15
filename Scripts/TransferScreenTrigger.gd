extends "res://Scripts/Triggerable.gd"


export var BackgroundColor: Color
export var TopText: String
export var TopColor: Color
export var BottomText: String
export var BottomColor: Color
export var DisplayLengthSeconds: float
export var TweenLengthSeconds: float
export var SetPlayerPosition: Vector2 # Set to 0,0 to keep current position

onready var PlayerNode = get_node("/root/Main/Player")
onready var GUI = PlayerNode.get_node("GUI")
onready var TransitionTween = get_node("Tween")
onready var TransparencyHolder = get_node("TransparencyHolder")
onready var TransferContainer:CanvasLayer = GUI.get_node("LevelTransition")
onready var Background:Panel = TransferContainer.get_node("bg")
onready var TopLabel:Label = TransferContainer.get_node("TopText")
onready var BottomLabel:Label = TransferContainer.get_node("BottomText")

var running = false

func onTriggerAny(trigger):
	running = true
	TopLabel.text = TopText
	TopLabel.add_color_override("font_color", TopColor)
	BottomLabel.text = BottomText
	BottomLabel.add_color_override("font_color", BottomColor)
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
	# Unpause game
	TransitionTween.start()
	yield(Main.wait(TweenLengthSeconds), "completed")
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
	
