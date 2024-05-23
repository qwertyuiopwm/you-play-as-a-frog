extends CanvasLayer


onready var Main = get_node("/root/Main")


func _ready():
	$BookBase/AnimatedSprite2.connect("animation_finished", self, "anim_fin")


func close():
	yield(Main.wait(3), "completed")
	visible = true
	yield(Main.wait(8), "completed")
	$BookBase/others.visible = false
	$BookBase/AnimatedSprite2.play("close")


func anim_fin():
	$ChangeScene.trigger(true)
	yield(Main.wait(1.5), "completed")
	visible = false
	$camfix.trigger(true)
