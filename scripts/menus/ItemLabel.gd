extends ActionButton
class_name ItemButton

@export var item: Item

func cursor_select()-> void:
	print(name)
	emit_signal("cursor_selected")

func _initialize(item: Item)-> void:
	self.item = item
	self.text = item.item_name.to_upper() + " - " + str(item.quantity)

