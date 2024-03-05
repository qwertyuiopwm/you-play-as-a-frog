extends LineEdit


export var NumericOnly:bool

var regex = RegEx.new()
var oldtext = text
func _ready():
	regex.compile("^[0-9]*$")
	connect("text_changed", self, "_on_text_changed")
	
func _on_text_changed(new_text: String):
	new_text.erase(max_length-1, 1)
	if not NumericOnly:
		return
	
	if regex.search(new_text):
		text = new_text
		oldtext = text
	else:
		text = oldtext
	set_cursor_position(text.length())

func _is_pos_in(checkpos:Vector2):
	if Rect2(Vector2(), rect_size).has_point(checkpos):
		return true
	return false
	
	
func _input(event):
	if not (event is InputEventMouseButton or event.is_action_pressed("ui_accept")):
		return
	if event is InputEventMouseButton and _is_pos_in(get_local_mouse_position()):
		return
	release_focus()
