extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]) -> void:
	var damage_type = DamageTypes.Fire
	for target in target_list:
		randomize()
		var dmg = randi_range(1,4) + parent.stats[UnitStats.magic]
		if(parent._calc_spell_hit(target)):
			dmg = target._aplly_weakness_and_resistance(dmg,damage_type)
			print(target.unit_name + " was burned for " + str(dmg)+ " damage.")
			_spawn_particles(target)
			target._receive_damage(dmg,damage_type)


