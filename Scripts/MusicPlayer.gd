extends Node

export var CurrentlyPlaying:String = "NONE"
var Songs = {}

func _ready():
	for node in self.get_children():
		Songs[String(node.name)] = node

func PauseSong(paused: bool):
	if CurrentlyPlaying == "NONE":
		return
	Songs[CurrentlyPlaying].get_tree().paused = paused

func PlaySongWithIntro(intro: String, song: String):
	StopMusic()
	
	var introFile = Songs[intro]
	PlaySong(intro)
	yield(introFile, "finished")
	if !introFile.playing:
		return
	
	PlaySong(song)

func StopMusic():
	if CurrentlyPlaying == "NONE": return
	Songs[CurrentlyPlaying].stop()
	CurrentlyPlaying = "NONE"

func PlaySong(song: String):
	if song == "NONE":
		StopMusic()
		return
	
	if not Songs.has(song):
		return
		
	print("Switching music from "+CurrentlyPlaying+" to "+song)
	StopMusic()
	Songs[song].play()
	CurrentlyPlaying = song

func PlayAtPosition(soundName: String, globalPosition: Vector2):
	if not Songs.has(soundName):
		return
	var newSound = Songs[soundName].duplicate()
	newSound.connect("finished", self, "onSoundFinish", [newSound])
	self.add_child(newSound)
	newSound.global_position = globalPosition
	newSound.play()

func PlayOnNode(soundName: String, node: Node):
	if not Songs.has(soundName):
		return
	var newSound = Songs[soundName].duplicate()
	newSound.connect("finished", self, "onSoundFinish", [newSound])
	node.add_child(newSound)
	newSound.position = Vector2.ZERO
	newSound.play()

func onSoundFinish(soundNode):
	soundNode.disconnect("finished", self, "onSoundFinish")
	soundNode.queue_free()
	pass
