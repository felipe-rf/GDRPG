extends Node2D

class_name TurnQueue

@onready var action_menu = $"../ActionMenu"
@onready var label = $"../Label"

var active_unit ##Current unit in queue

var unit_list:Array[Unit] ##All alive units
var unit_list_sorted:Array[Unit]

var player_list:Array[Unit]##All player units, alive or not

func _get_unit_list() -> Array[Unit]: ##Returns all units
	var prelist = get_children().filter(func(element): return element is Unit)
	var list:Array[Unit]
	list.assign(prelist)
	unit_list_sorted = list
	unit_list_sorted.sort_custom(func(a, b): return a.base_stats[UnitStats.speed] > b.base_stats[UnitStats.speed])
	return list

func _refresh_unit_list(list: Array[Unit]) -> Array[Unit]: ##Returns list without dead units 
	list = list.filter(func(element):return element.state != 2)
	unit_list_sorted = unit_list_sorted.filter(func(element):return element.state != 2)
	return list
	
func _initialize() -> void: ##Initializes lists 
	unit_list = _get_unit_list()
	player_list = _get_unit_list().filter(func(element): return element is PlayerUnit)
	active_unit = unit_list_sorted[0]

func _start() -> void: ##Starts combat
	_initialize()
	_play_turn()

func _play_turn() -> void:
	##Activates unit and menu
	active_unit._activate(unit_list)
	active_unit._play_turn()
	action_menu._initialize(active_unit)
	await active_unit.turnEnded
	##Refresh unit list
	active_unit._deactivate()
	unit_list = _refresh_unit_list(unit_list)
	##Lose
	if(unit_list.filter(func(element): return element is PlayerUnit).size() == 0): 
		label.text = "You Lost"
		label.visible = true
		print("You Lost")
		return
	##Win
	if(unit_list.filter(func(element): return element is EnemyUnit).size() == 0): 
		label.visible = true
		print("You Won")
		return
	##Get next unit and moves on to next turn
	var new_index : int = (unit_list_sorted.find(active_unit)+1) % unit_list_sorted.size()
	active_unit = unit_list_sorted[new_index]
	_play_turn()
