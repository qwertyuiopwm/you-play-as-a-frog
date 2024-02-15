extends Node

export var CurrentlyPlaying = "ForestMusic"

export var Songs = {}

func _ready():
	for node in self.get_children():
		Songs[String(node.name)] = node

func PlaySong(song: String):
	Songs[CurrentlyPlaying].stop()
	Songs[song].play()
	CurrentlyPlaying = song
