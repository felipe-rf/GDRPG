extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	var hit = parent._rand20()
	randomize()
	var dmg = randi_range(1,5) + parent.magic
	if(hit == 1):
		parent._miss_attack()
	elif(hit+parent.precision<target.speed):
		parent._miss_attack()
	elif(hit+parent.precision>target.speed):
		print(target.unit_name + " received " + str(dmg)+ " ice damage.")
		target._receive_damage(dmg)
		target._aplly_stat_change(1,UnitStats.speed,2)


	

	
	
