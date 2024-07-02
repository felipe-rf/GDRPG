extends Spell

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	for target in target_list:
		var hit = parent._rand20()
		randomize()
		var dmg = randi_range(1,10) + parent.magic
		if(hit == 1):
			parent._miss_attack()
		elif(hit+parent.precision<target.speed):
			parent._miss_attack()
		elif(hit+parent.precision>target.speed):
			print(target.unit_name + " was burned for " + str(dmg)+ " damage.")
			target._receive_damage(dmg)


		
		
