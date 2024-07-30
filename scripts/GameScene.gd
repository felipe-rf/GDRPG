extends Node2D

@export var combat_finished: PackedScene
@export var combat_scene: PackedScene
@onready var dungeon_map = $dungeon_map
@onready var player_units = PlayerUnits
var players: Array[PlayerCharacter]
@onready var savestate = $Savestate
@export var next_scene: Resource
signal finished

func _ready():
	savestate.load_game_state()
	savestate.unpack_level(self)
	savestate.get_game_variables(PlayerUnits)
	Globals.current_level = scene_file_path
	var player_list = SceneSwitcher.get_param("player_list")
	if player_list != null:
		for i in player_units.get_children():
			i.queue_free()
		for i in player_list:
			player_units.add_child(i.instantiate())
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

func _end_combat(_player_units: Array[PlayerCharacter], _exp: int, current_scene):
	var new_scene: FinishedScreen = combat_finished.instantiate()
	new_scene._initialize(_player_units,_exp)
	add_child(new_scene)
	current_scene.queue_free()

func _return_to_dungeon(player_units: Array[PlayerCharacter],current_scene):
	_enable_scene(dungeon_map)
	emit_signal("finished")
	current_scene.queue_free()

func _switch_scene():
	savestate.load_game_state()
	savestate.pack_level(self)
	savestate.save_game_state()
	savestate.set_game_variables(Globals)
	savestate.set_game_variables(PlayerUnits)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
