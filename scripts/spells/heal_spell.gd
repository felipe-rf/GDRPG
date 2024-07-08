extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	randomize()
	var heal = randi_range(1,8)
	_spawn_particles(target)
	target._receive_healing(heal)

	
	
