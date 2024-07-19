extends Node2D

@export var player_units: Array[PlayerCharacter]
@export var enemy_units: Array[UnitCharacter]

@export var enemy_scene: PackedScene
@export var player_scene: PackedScene

@export var player_inventory: PlayerInventory
@onready var turn_queue = $TurnQueue

@onready var players = $PositionMarkers/Players
@onready var enemies = $PositionMarkers/Enemies

func _ready() -> void: ##Initializes units and starts turn queue
	for i in player_units.size():
		var unit = player_scene.instantiate()
		turn_queue.add_child(unit)
		unit._initialize(player_units[i])
		unit.global_position = players.get_child(i).global_position
	
	for i in enemy_units.size():
		var unit = enemy_scene.instantiate()
		turn_queue.add_child(unit)
		unit._initialize(enemy_units[i])
		unit.global_position = enemies.get_child(i).global_position

	turn_queue._start()

