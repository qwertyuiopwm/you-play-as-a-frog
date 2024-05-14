extends Label


export var Property: String = "state"
export var checkedNode: NodePath

onready var checked = get_node(checkedNode) if checkedNode else get_parent()

func _ready():
	visible = OS.is_debug_build()


func _process(_delta):
	
	text = str(checked.get(Property))
