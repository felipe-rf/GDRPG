extends Unit
class_name PlayerUnit

func _get_allies(list:Array[Unit]):
	allies_list = list.filter(func(element):return element is PlayerUnit)

func _get_enemies(list:Array[Unit]):
	enemies_list = list.filter(func(element):return element is EnemyUnit)
