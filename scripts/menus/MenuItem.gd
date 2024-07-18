extends Label
class_name MenuItem

signal cursor_selected()

func cursor_select()-> void:
	#print(name)
	emit_signal("cursor_selected")
