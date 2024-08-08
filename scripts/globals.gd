extends Node

var current_level ="res://scenes/game_scene.tscn"
var has_control = false
var current_save = 4
var player_name = "Felipe"
func set_control(control: bool):
	has_control = control
