extends Node2D

class_name TurnQueue

var active_unit
var unit_list:Array[Unit]

func _get_unit_list():
	var prelist = get_children().filter(func(element): return element is Unit)
	var list:Array[Unit]
	list.assign(prelist)
	list.sort_custom(func(a, b): return a.speed > b.speed)
	return list

	
func _refresh_unit_list(list: Array[Unit]):
	list = list.filter(func(element):return element.state != 2)
	return list
	
func _initialize():
	unit_list = _get_unit_list()
	active_unit = unit_list[0]

func _ready():
	_initialize()
	_play_turn()

func _play_turn():
	active_unit._activate(unit_list)
	await active_unit.turnEnded
	active_unit._deactivate()
	unit_list = _refresh_unit_list(unit_list)
	if(unit_list.filter(func(element): return element is PlayerUnit).size() == 0): 
		print("You Lost")
		return
	if(unit_list.filter(func(element): return element is EnemyUnit).size() == 0): 
		print("You Won")
		return
	var new_index : int = (unit_list.find(active_unit)+1) % unit_list.size()
	active_unit = unit_list[new_index]
	_play_turn()
