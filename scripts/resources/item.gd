extends Resource
class_name Item

@export var icon: Texture2D
@export var item_name: String
@export var description: String
@export var target_type: int
@export var particle: PackedScene
@export var quantity: int = 1

func _item_effect(parent: Unit,target_list: Array[Unit])-> void: ##Executes the item effect
	print("this shouldn't happen ;-;")

func _spawn_particles(target: Unit) -> void: ##Spawns particles on target
	if particle != null:
		var instance = particle.instantiate()
		target.add_child(instance)
