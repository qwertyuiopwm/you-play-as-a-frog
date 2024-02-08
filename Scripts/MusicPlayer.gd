extends Node

export var CurrentlyPlaying = "ForestMusic"

export var Songs = {}

func _ready():
	for node in self.get_children():
		Songs[String(node.name)] = node

func PlaySong(song: String):
	print(Songs)
	print(song)
	Songs[CurrentlyPlaying].stop()
	print("trying to stop node", Songs[CurrentlyPlaying])
	print("trying to play node", Songs[song])
	Songs[song].play()
	CurrentlyPlaying = song
