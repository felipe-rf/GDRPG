extends Node2D
class_name CombatScene

@export var player_units: Array[PlayerCharacter]
@export var enemy_units: Array[PackedScene]
@onready var camera_2d = $Camera2D

@export var enemy_scene: PackedScene
@export var player_scene: PackedScene

@export var finish_screen: PackedScene


@export var player_inventory: PlayerInventory
@onready var turn_queue = $TurnQueue

@onready var players = $PositionMarkers/Players
@onready var enemies = $PositionMarkers/Enemies
@onready var animation_player = $"../AnimationPlayer"


var exp_gained = 0
func _initialize(_players: Array[PlayerCharacter],_enemies: Array[PackedScene]):
	player_units = _players
	enemy_units = _enemies
	

func _ready() -> void: ##Initializes units and starts turn queue
	player_inventory = get_parent().get_node("PlayerInventory")
	for i in player_units.size():
		var unit = player_scene.instantiate()
		turn_queue.add_child(unit)
		unit._initialize(player_units[i])
		unit.global_position = players.get_child(i).global_position
	
	for i in enemy_units.size():
		var unit = enemy_scene.instantiate()
		var unit_data = enemy_units[i].instantiate()
		turn_queue.add_child(unit)
		unit._initialize(unit_data)
		unit.global_position = enemies.get_child(i).global_position
	turn_queue._initialize()

	await animation_player.animation_finished
	turn_queue._start()

func _finish(units: Array[Unit]) -> void:
	var i = 0
	for character in player_units:
		character.update(exp_gained,units[i].stats)
		i+=1
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	get_parent()._end_combat(player_units,exp_gained,self)

func _disable():
	camera_2d.enabled = false

func _enable():
	camera_2d.enabled = true
