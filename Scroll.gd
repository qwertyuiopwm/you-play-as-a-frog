extends ScrollContainer


export var PIXEL_PER_SECOND = 10

var scroll: float


func _process(delta):
	visible = get_parent().get_parent().visible
	
	if not visible: return
	scroll += PIXEL_PER_SECOND * delta
	print(scroll_vertical, " ", scroll)
	scroll_vertical = int(scroll)
