extends Area2D


export var Triggerables: Array
export var CanOn = true
export var CanOff = false
export var Reusable = false
export var InverseSignal = false
export var Music = ""

onready var PlayerNode = load("res://Player.tscn").instance()
onready var MusicPlayer = PlayerNode.get_node("MusicPlayer")

func trigger(_trigger: bool):
	if Music != "":
		MusicPlayer.PlaySong(Music)
	
	for triggerable in Triggerables:
		get_node(triggerable).trigger(_trigger)


func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") and CanOn:
		trigger(!InverseSignal)
		if !Reusable: queue_free()


func _on_PlayerDetector_body_exited(body):
	if body.is_in_group("Player") and CanOff:
		trigger(InverseSignal)
		if !Reusable: queue_free()
