extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void:
	var target = target_list[0]
	_spawn_particles(target)
	target._aplly_stat_change(target.base_stats[UnitStats.speed]/2,UnitStats.speed,2)
	target._aplly_stat_change(target.base_stats[UnitStats.precision]/2,UnitStats.precision,2)
	
	
	
