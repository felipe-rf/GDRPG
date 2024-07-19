extends Item

func _item_effect(parent: Unit,target_list: Array[Unit]) -> void:
	var target = target_list[0]
	var heal = 10
	_spawn_particles(target)
	target._receive_healing(heal)

