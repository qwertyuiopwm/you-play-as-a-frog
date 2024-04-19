extends ScrollContainer


export var PIXEL_PER_SECOND = 10
export var FADE_DELAY: float = 5
export var FADE_DURATION: float = 5

var scroll: float

enum states {
	SCROLLING,
	FADING,
	DONE,
}

var state = states.SCROLLING


func _process(delta):
	match state:
		states.SCROLLING:
			visible = get_parent().get_parent().visible
			
			if not visible: return
			scroll += PIXEL_PER_SECOND * delta
			scroll_vertical = int(scroll)
			if scroll > scroll_vertical + (PIXEL_PER_SECOND * FADE_DELAY):
				state = states.FADING
		
		states.FADING:
			modulate.a -= (1.0 / FADE_DURATION) * delta
			if modulate.a >= 0: return
			state = states.DONE
