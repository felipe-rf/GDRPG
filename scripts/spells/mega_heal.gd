extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void:
	randomize()
	var heal = randi_range(1,8)
	for target in target_list:
		_spawn_particles(target)
		target._receive_healing(heal)
