extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	_spawn_particles(target)
	target._aplly_stat_change(target.base_strenght*2,UnitStats.strength,2)
	
	
	
