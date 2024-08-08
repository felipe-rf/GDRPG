extends Node



var last_save_file = ""
var last_visited_scene = "res://scenes/game_scene.tscn"
signal autosave_finished
var save_time
var player_name: String = "cattt"
var auto_save = false
var current_save = 3
func manual_load(savestate: ThothGameState,save_file: String):
	savestate.save_filename = save_file
	last_save_file = save_file
	savestate.load_game_state()
	savestate.get_game_variables(PlayerUnits)
	savestate.get_game_variables(SaveManager)
	Globals.current_save = current_save
	Globals.player_name = player_name
	get_tree().change_scene_to_file(last_visited_scene)

func was_level_visited(savestate,level):
	savestate.save_filename = last_save_file
	return savestate.visited_level(level)

func scene_load_last_save(savestate,current_scene):
	savestate.save_filename = last_save_file
	savestate.load_game_state()
	savestate.unpack_level(current_scene)
	savestate.get_game_variables(PlayerUnits)
	savestate.get_game_variables(SaveManager)
	Globals.current_save = current_save
	Globals.player_name = player_name

func manual_save(savestate: ThothGameState,current_scene,filename):
	current_save = Globals.current_save
	player_name = Globals.player_name
	savestate.save_filename = last_save_file
	savestate.save_filename = filename
	last_save_file = filename
	savestate.pack_level(current_scene)
	savestate.set_game_variables(PlayerUnits)
	save_time = Time.get_datetime_string_from_system(false,true)
	auto_save = false
	savestate.set_game_variables(SaveManager)
	savestate.save_game_state()


func scene_save_autosave(savestate: ThothGameState,current_scene):
	current_save = Globals.current_save
	player_name = Globals.player_name
	savestate.save_filename = last_save_file
	savestate.load_game_state()
	var filename = "auto_"+ str(current_save) +".sav"
	savestate.save_filename = filename
	last_save_file = filename
	savestate.pack_level(current_scene)
	savestate.set_game_variables(PlayerUnits)
	save_time = Time.get_datetime_string_from_system(false,true)
	auto_save = true
	savestate.set_game_variables(SaveManager)
	savestate.save_game_state()
	print("SAVED AT " + filename)

	
