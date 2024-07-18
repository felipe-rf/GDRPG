extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void:
	var target = target_list[0]
	_spawn_particles(target)
	target._aplly_stat_change(target.base_stats[UnitStats.strength]*2,UnitStats.strength,2)

