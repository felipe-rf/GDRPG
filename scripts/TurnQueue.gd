extends Node2D

class_name TurnQueue
@onready var action_menu = $"../ActionMenu"
@onready var label = $"../Label"




var active_unit
var unit_list:Array[Unit]
var unit_list_sorted:Array[Unit]
var player_list:Array[Unit]
func _get_unit_list():
	var prelist = get_children().filter(func(element): return element is Unit)
	var list:Array[Unit]
	list.assign(prelist)
	unit_list_sorted = list
	unit_list_sorted.sort_custom(func(a, b): return a.speed > b.speed)
	return list

	
func _refresh_unit_list(list: Array[Unit]):
	list = list.filter(func(element):return element.state != 2)
	unit_list_sorted = unit_list_sorted.filter(func(element):return element.state != 2)
	return list
	
func _initialize():
	unit_list = _get_unit_list()
	player_list = _get_unit_list().filter(func(element): return element is PlayerUnit)
	active_unit = unit_list_sorted[0]

func _start():
	_initialize()
	_play_turn()

func _play_turn():
	active_unit._activate(unit_list)
	active_unit._play_turn()
	action_menu._initialize(active_unit)
	await active_unit.turnEnded
	active_unit._deactivate()
	unit_list = _refresh_unit_list(unit_list)
	if(unit_list.filter(func(element): return element is PlayerUnit).size() == 0): 
		label.text = "You Lost"
		label.visible = true
		print("You Lost")
		return
	if(unit_list.filter(func(element): return element is EnemyUnit).size() == 0): 
		label.visible = true
		print("You Won")
		return
	var new_index : int = (unit_list_sorted.find(active_unit)+1) % unit_list_sorted.size()
	active_unit = unit_list_sorted[new_index]
	_play_turn()
