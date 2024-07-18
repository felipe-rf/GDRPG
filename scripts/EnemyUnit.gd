extends Unit

class_name EnemyUnit

func _get_allies(list:Array[Unit]) -> Array[Unit]:
	return list.filter(func(element):return element is EnemyUnit)

func _get_enemies(list:Array[Unit]) -> Array[Unit]:
	return list.filter(func(element):return element is PlayerUnit)

func _play_turn() -> void: ##Plays enemy's turn
	if state == UnitState.Active:
		_attack_unit(enemies_list.pick_random())
