extends Node2D

@export var combat_finished: PackedScene
@export var combat_scene: PackedScene
@onready var dungeon_map = $dungeon_map
@onready var player_units = PlayerUnits
@onready var savestate = $Savestate
@export var next_scene: Resource
signal finished
@onready var animation_player = $AnimationPlayer

@onready var gui_manager = $GUIManager



func _ready():
	if SaveManager.was_level_visited(savestate,self):
		SaveManager.scene_load_last_save(savestate,self)

	SaveManager.last_visited_scene = scene_file_path
	Dialogic.signal_event.connect(dialogic_signal)
	_enable_scene(dungeon_map)
	await animation_player.animation_finished
	Globals.has_control = true
			

func dialogic_signal(arg: String):
	if arg == "save_game":
		_pause_scene(dungeon_map)
		gui_manager.save_game()

func return_to_game():
	_unpause_scene(dungeon_map)
	
func _unpause_scene(scene: Node2D):
	scene.process_mode = Node.PROCESS_MODE_INHERIT
func _pause_scene(scene: Node2D):
		scene.process_mode = Node.PROCESS_MODE_DISABLED


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
	new_scene._initialize(player_units.get_player_list(),enemy_units)
	_disable_scene(dungeon_map)
	add_child(new_scene)
	animation_player.play("Transition_in")
	

func _end_combat(_player_units: Array[PlayerCharacter], _exp: int, current_scene):
	var new_scene: FinishedScreen = combat_finished.instantiate()
	new_scene._initialize(_player_units,_exp)
	add_child(new_scene)
	animation_player.play("Transition_in")
	current_scene.queue_free()

func _return_to_dungeon(player_units: Array[PlayerCharacter],current_scene):
	_enable_scene(dungeon_map)
	current_scene.queue_free()
	animation_player.play("Transition_in")
	await animation_player.animation_finished
	emit_signal("finished")


func _switch_scene():
	Globals.has_control = false
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	SaveManager.scene_save_autosave(savestate,self)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
