extends "res://Scripts/BaseScripts/Trigger.gd"


func _ready():
	Player.connect("death_scene_finished", self, "on_player_death")


func on_player_death():
	trigger(TriggerVal)
