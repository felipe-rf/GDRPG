extends Node2D

@onready var camera_2d = $CharacterBody2D/Camera2D

@onready var animation_player = $AnimationPlayer
@export var combat_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
@onready var savestate = $"../Savestate"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _start_combat(enemies: Array[PackedScene]) -> void:
	animation_player.play("Transition_out")
	await animation_player.animation_finished
	get_parent()._start_combat(enemies)
	
func _disable():
	camera_2d.enabled = false

func _enable():
	animation_player.play("Transition_in")
	camera_2d.enabled = true


func _on_button_pressed():
	 # first you need to load the state on the disk
	# this is needed because there might be information about other game states
	savestate.load_game_state()
	# this appends the current level node's data to the game state
	savestate.pack_level(get_parent())
	# finally it is saved to the disk
	savestate.save_game_state()


func _on_button_2_pressed():
		# first load the state of the game from the disk
	savestate.load_game_state()
	# unpack that state loaded into this scene
	# this will remove all the objects from the node objects
	# and will populate it with the objects as written in the file on disk
	savestate.unpack_level(get_parent())
