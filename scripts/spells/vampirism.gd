extends Spell

@export var heal_particle: PackedScene

func _spell_effect(parent: Unit,target_list: Array[Unit]):
	var target = target_list[0]
	var hit = parent._rand20()
	var damage_type = DamageTypes.Piercing
	randomize()
	var dmg = randi_range(1,8) + parent.stats[UnitStats.magic]
	if(parent._calc_spell_hit(target)):
		dmg = target._aplly_weakness_and_resistance(dmg,damage_type)
		print(target.unit_name + " received " + str(dmg)+ " piercing damage.")
		target._receive_damage(dmg,damage_type)
		_spawn_particles(target)
		_spawn_second_particles(parent)
		parent._receive_healing(dmg)

func _spawn_second_particles(target: Unit):
	if heal_particle != null:
		var instance = heal_particle.instantiate()
		target.add_child(instance)
