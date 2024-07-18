extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void:
	var target = target_list[0]
	var damage_type = DamageTypes.Ice
	randomize()
	var dmg = randi_range(1,10) + parent.stats[UnitStats.magic]
	if(parent._calc_spell_hit(target)):
		dmg = target._aplly_weakness_and_resistance(dmg,damage_type)
		print(target.unit_name + " received " + str(dmg)+ " ice damage.")
		target._receive_damage(dmg,damage_type)
		_spawn_particles(target)
		target._aplly_stat_change(target.base_stats[UnitStats.speed]/2,UnitStats.speed,2)
