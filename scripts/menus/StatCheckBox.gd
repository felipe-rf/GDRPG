extends CheckBox

@export var stat:int
signal toggled_on(stat: int)
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("toggled",Callable(self,"_toggled_on"))


func _toggled_on(toggled_on):
	if(toggled_on):
		emit_signal("toggled_on",stat)
