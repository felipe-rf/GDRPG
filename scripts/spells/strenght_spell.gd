extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	target._aplly_stat_change(target.strenght*2,UnitStats.strenght,2)

	
	
