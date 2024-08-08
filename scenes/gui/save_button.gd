extends Button
class_name SaveButton

signal _pressed(parent)
signal _focused(parent)
@export var save: String
@export var save_number: int = 0
func _ready():
	connect("pressed",Callable(self,"_emit_pressed"))
	connect("focus_entered",Callable(self,"_emit_focused"))
	connect("mouse_entered",Callable(self,"_on_mouse_entered"))
	connect("mouse_exited",Callable(self,"_on_mouse_exited"))
	
func _on_mouse_entered():
	self.grab_focus()


func _emit_focused():
	emit_signal("_focused",self)
	
func _emit_pressed():
	emit_signal("_pressed",self)
