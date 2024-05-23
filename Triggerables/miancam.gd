extends Triggerable


func onTriggerAny(_t):
	var e: Camera2D = get_node("/root/Main/Player/Camera2D")
	e.current = true
