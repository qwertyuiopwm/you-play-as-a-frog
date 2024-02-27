extends Node


export var Song:String

onready var PlayerNode = get_node("/root/Main/Player")
onready var MusicPlayer = PlayerNode.get_node("MusicPlayer")

func trigger(close_):
	MusicPlayer.PlaySong(Song)
