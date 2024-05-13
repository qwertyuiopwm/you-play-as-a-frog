extends "res://Scripts/BaseScripts/Triggerable.gd"


onready var Player = Main.get_node("Player")
onready var PlayerCamera = Player.get_node("Camera2D")

export var ChangeTime: float = 2

export var ZoomChange: Vector2 = Vector2.ZERO

export var CamOffset: Vector2 = Vector2.ZERO

export var FreezePlayer: bool = true


func _ready():
	var _c = $MoveTween.connect("tween_completed", self, "MoveTween_completed")


func onTriggerAny(_trigger):
	Player.can_move = not FreezePlayer
	
	$MoveTween.interpolate_property(PlayerCamera, "position", 
		PlayerCamera.position, 
		CamOffset, 
		ChangeTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$MoveTween.start()
	$ZoomTween.interpolate_property(PlayerCamera, "zoom", 
		PlayerCamera.zoom, 
		PlayerCamera.zoom + ZoomChange, 
		ChangeTime, Tween.TRANS_EXPO, Tween.EASE_IN_OUT
	)
	$ZoomTween.start()


func MoveTween_completed(_p1, _p2):
	Player.can_move = true
