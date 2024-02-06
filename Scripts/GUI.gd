extends Control

onready var hpPanel = $CanvasLayer/top_bar/stats_bg/VBoxContainer/stats/HP_Canvas/Panel
onready var Player = get_parent()

onready var maxHpSize = hpPanel.rect_size.x

func _process(_delta):
	var newHealthX = (maxHpSize/Player.maxHealth)*Player.health
	var newRectSize = Vector2(newHealthX, 16)
	hpPanel.set_size(newRectSize)
