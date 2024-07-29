extends Node2D

@export var combat_finished: PackedScene
@export var combat_scene: PackedScene
@onready var dungeon_map = $dungeon_map
@onready var player_units = $PlayerUnits
var players: Array[PlayerCharacter]

signal finished

func _ready():
	_enable_scene(dungeon_map)
	for i in player_units.get_children():
		if i is PlayerCharacter:
			players.append(i)
# Called when the node enters the scene tree for the first time.
func _enable_scene(scene: Node2D):
		scene.process_mode = Node.PROCESS_MODE_INHERIT
		scene.visible = true
		scene._enable()
			
func _disable_scene(scene: Node2D):
		scene.process_mode = Node.PROCESS_MODE_DISABLED
		scene.visible = false
		scene._disable()

func _start_combat(enemy_units: Array[PackedScene]):

	var new_scene: CombatScene = combat_scene.instantiate()
	new_scene._initialize(players,enemy_units)
	_disable_scene(dungeon_map)
	add_child(new_scene)

func _end_combat(player_units: Array[PlayerCharacter], exp: int, current_scene):
	var new_scene: FinishedScreen = combat_finished.instantiate()
	new_scene._initialize(player_units,exp)
	add_child(new_scene)
	current_scene.queue_free()

func _return_to_dungeon(player_units: Array[PlayerCharacter],current_scene):
	_enable_scene(dungeon_map)
	emit_signal("finished")
	current_scene.queue_free()
