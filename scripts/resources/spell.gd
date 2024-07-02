extends Resource
class_name Spell

@export var icon: Texture2D
@export var spell_name: String
@export var description: String
@export var target_type: int

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	print("this shouldn't happen ;-;")
