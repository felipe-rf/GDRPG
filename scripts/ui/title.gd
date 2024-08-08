extends Control

@onready var savestate = $Savestate
@onready var animation_player = $AnimationPlayer
@onready var main_screen = $MainScreen

@export var new_game_screen: PackedScene
@export var load_screen: PackedScene
var current_screen: PackedScene
var previous_screen: PackedScene
		
func _on_start_pressed():
	var screen = new_game_screen.instantiate()
	self.add_child(screen)
	main_screen.visible = false


func start_game():
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(SaveManager.last_visited_scene)

func display_new_game():
	var save_load_screen = load_screen.instantiate()
	self.add_child(save_load_screen)
	main_screen.visible = false

func return_to_main():
	main_screen.visible = true

func _on_start_2_pressed():
	var save_load_screen = load_screen.instantiate()
	self.add_child(save_load_screen)
	main_screen.visible = false
