extends Control

@onready var savestate = $Savestate
@onready var animation_player = $AnimationPlayer
@onready var start_2 = $VBoxContainer/Start2

func _ready():
	if savestate.save_exists():
		start_2.disabled = false
	else:
		start_2.disabled = true
		
func _on_start_pressed():
	var dir = DirAccess.open("user://")
	dir.remove("savegame.sav")
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(Globals.current_level)
	


func _on_start_2_pressed():
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(Globals.current_level)
