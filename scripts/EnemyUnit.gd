extends Unit
class_name EnemyUnit

func _get_allies(list:Array[Unit]):
	allies_list = list.filter(func(element):return element is EnemyUnit)

func _get_enemies(list:Array[Unit]):
	enemies_list = list.filter(func(element):return element is PlayerUnit)

func _play_turn():
	if state == UnitState.Active:
		_attack_unit(enemies_list.pick_random())
