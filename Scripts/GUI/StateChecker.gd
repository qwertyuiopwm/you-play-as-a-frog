extends Label


onready var parent = get_parent()


func _ready():
	visible = OS.is_debug_build()


func _process(_delta):
	text = str(parent.state)
