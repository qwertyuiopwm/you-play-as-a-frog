extends "res://Scripts/BaseScripts/Triggerable.gd"


export var Song: String
export var Intro: String

onready var PlayerNode = get_node("/root/Main/Player")
onready var MusicPlayer = PlayerNode.get_node("MusicPlayer")

func onTriggerAny(_trigger):
	if Intro:
		MusicPlayer.PlaySongWithIntro(Intro, Song)
		return
	
	MusicPlayer.PlaySong(Song)
