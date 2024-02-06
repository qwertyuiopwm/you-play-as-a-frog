extends TileMap

export var OpenOffset = Vector2(0, 0)
export var Hide = true
export var StartClosed = false

onready var startPos = self.position
onready var openPos = self.position + OpenOffset

func trigger(close: bool):
	self.position = (startPos if close else openPos)
	
	if !Hide: return
	self.visible = close

func _ready():
	self.trigger(StartClosed)
