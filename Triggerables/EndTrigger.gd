extends Triggerable


func onTriggerAny(_trigger):
	get_node("/root/Main/Player/GUI").close()
