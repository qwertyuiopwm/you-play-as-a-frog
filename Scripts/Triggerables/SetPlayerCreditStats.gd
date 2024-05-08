extends "res://Scripts/BaseScripts/Triggerable.gd"


onready var Player = Main.get_node("Player")


func onTriggerAny(_trigger):
	Player.god_enabled = true
	Player.PlayerSpells = []
	Player.AddSpell("Dev_Beam")
	Player.selected_spell = Player.PlayerSpells[0]
	print("player stats updated")
