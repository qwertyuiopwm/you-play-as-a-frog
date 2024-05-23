extends CanvasLayer

onready var Main = get_node("/root/Main")
onready var GUI = get_parent()
onready var Frames = $book/BookBase/Frames.get_children()
onready var BookChange = $book/BookOver/bookchange

var curr_frame: int = 0
var tween: Tween = Tween.new()
var can_change: bool = true


func _ready():
	var _c = BookChange.connect("frame_changed", self, "frame_changed")
	var __c = BookChange.connect("animation_finished", self, "animation_finished")
	Main.call_deferred("add_child", tween)


func _physics_process(_delta):
	if Input.is_action_just_pressed("move_right"):
		if BookChange.animation == "open":
			BookChange.playing = true
		else:
			next_page()
	if Input.is_action_just_pressed("move_left"):
		prev_page()


func next_page():
	if not can_change:
		return
	if curr_frame >= len(Frames) - 1:
		can_change = false
		start_game()
		return
	
	BookChange.play("next page")
	
	if curr_frame >= 0:
		Frames[curr_frame].visible = false
	
	BookChange.frame = 1
	
	curr_frame = min(len(Frames) - 1, curr_frame + 1)
	Frames[curr_frame].visible = true


func prev_page():
	if not can_change:
		return
	if curr_frame <= 0:
		return
	BookChange.play("prev page")
	
	if curr_frame >= 0:
		Frames[curr_frame].visible = false
	
	BookChange.frame = 1
	
	curr_frame = max(0, curr_frame - 1)
	Frames[curr_frame].visible = true


func frame_changed():
	var frame = BookChange.frame
	var frame_count = BookChange.frames.get_frame_count(BookChange.animation)
	$book/BookBase.visible = (frame <= 1 or frame >= (frame_count - 2))
	if BookChange.animation == "open" and frame < 5:
		$book/BookBase.visible = false


func animation_finished():
	match BookChange.animation:
		"open":
			BookChange.playing = false
			BookChange.animation = "next page"
		"next page", "prev_page":
			var sel_frame = Frames[curr_frame]
			if sel_frame is AnimatedSprite:
				sel_frame.frame = 0
				sel_frame.playing = true


func start_game():
	GUI.get_node("MainMenu").visible = false
	visible = false
	Main.pause(false, [])
	$ChangeScene.trigger(true)
