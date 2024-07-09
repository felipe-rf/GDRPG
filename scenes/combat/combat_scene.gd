extends Node2D

@export var player_units: Array[PackedScene]
@export var enemy_units: Array[PackedScene]

@onready var turn_queue = $TurnQueue

@onready var players = $PositionMarkers/Players
@onready var enemies = $PositionMarkers/Enemies

func _ready():
	for i in player_units.size():
		var unit = player_units[i].instantiate()
		if not unit is PlayerUnit:
			unit.queue_free()
			pass
		turn_queue.add_child(unit)
		unit.global_position = players.get_child(i).global_position
	
	for i in enemy_units.size():
		var unit = enemy_units[i].instantiate()
		if not unit is EnemyUnit:
			unit.queue_free()
			pass
		turn_queue.add_child(unit)
		unit.global_position = enemies.get_child(i).global_position

	turn_queue._start()

