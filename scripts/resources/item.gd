extends Resource
class_name Item

@export var icon: Texture2D
@export var item_name: String
@export var description: String
@export var target_type: int

func _item_effect(parent: Unit,target_list: Array[Unit])-> void: ##Executes the item effect
	print("this shouldn't happen ;-;")
