extends Area2D
class_name UnitArea
signal _mouse_entered(parent)

func _ready():
	connect("mouse_entered",Callable(self,"_on_mouse_entered"))
	
func _on_mouse_entered():
	emit_signal("_mouse_entered",self)
