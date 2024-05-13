extends "res://Scripts/BaseScripts/Triggerable.gd"


onready var Player = Main.get_node("Player")
onready var PlayerCamera = Player.get_node("Camera2D")

export var SlidePosPath: NodePath

export var SlideTime: float = 2
export var SlideBackTime: float = 2
export var FreezeTime: float = 5

export var ZoomChange: Vector2 = Vector2.ZERO
export var EndZoomChange: Vector2 = Vector2.ZERO

export var EndCamOffset: Vector2 = Vector2.ZERO

export var FreezePlayer: bool = true

onready var slidePos: Node = get_node(SlidePosPath)

enum states {
	SLIDING_TO,
	SLIDING_BACK,
}

var state


func _ready():
	var _c = $MoveTween.connect("tween_completed", self, "MoveTween_completed")


func onTriggerAny(_trigger):
	state = states.SLIDING_TO
	Player.can_move = not FreezePlayer
	$Camera2D.current = true
	
	$MoveTween.interpolate_property($Camera2D, "global_position", 
		Player.global_position, 
		slidePos.global_position, 
		SlideTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$ZoomTween.interpolate_property($Camera2D, "zoom", 
		PlayerCamera.zoom, 
		PlayerCamera.zoom + ZoomChange, 
		SlideTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$MoveTween.start()
	$ZoomTween.start()


func MoveTween_completed(_p1, _p2):
	if state == states.SLIDING_BACK:
		Player.can_move = true
		PlayerCamera.current = true
		return
	
	state = states.SLIDING_BACK
	yield(Main.wait(FreezeTime), "completed")
	
	$MoveTween.interpolate_property($Camera2D, "global_position", 
		slidePos.global_position, 
		Player.global_position + EndCamOffset, 
		SlideBackTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$ZoomTween.interpolate_property($Camera2D, "zoom", 
		PlayerCamera.zoom + ZoomChange, 
		PlayerCamera.zoom + EndZoomChange, 
		SlideBackTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$MoveTween.start()
	$ZoomTween.start()
	PlayerCamera.zoom += EndZoomChange
	PlayerCamera.position = EndCamOffset
