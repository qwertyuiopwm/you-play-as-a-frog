extends Node

export var CurrentlyPlaying:String = "NONE"

export var Songs = {}

func _ready():
	for node in self.get_children():
		Songs[String(node.name)] = node

func PlaySong(song: String):
	print("Switching music from "+CurrentlyPlaying+" to "+song)
	if CurrentlyPlaying != "NONE":
		Songs[CurrentlyPlaying].stop()
	Songs[song].play()
	CurrentlyPlaying = song
