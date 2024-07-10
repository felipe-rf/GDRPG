extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	_spawn_particles(target)
	target._aplly_stat_change(target.base_speed/2,UnitStats.speed,2)
	target._aplly_stat_change(target.base_precision/2,UnitStats.precision,2)
	
	
	
