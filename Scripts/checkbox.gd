extends CheckBox


func _ready():
	connect("pressed", self, "_on_button_press")

func _on_button_press():
	release_focus()
