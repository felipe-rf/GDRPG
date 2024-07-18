extends Resource
class_name Spell

@export var icon: Texture2D
@export var spell_name: String
@export var description: String
@export var target_type: int
@export var particle: PackedScene

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void: ##Executes the spell's effect
	print("this shouldn't happen ;-;")

func _spawn_particles(target: Unit) -> void: ##Spawns particles on target
	if particle != null:
		var instance = particle.instantiate()
		target.add_child(instance)
