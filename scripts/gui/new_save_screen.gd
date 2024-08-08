extends Control

@onready var savestate = $Savestate
@onready var button = $Button

@onready var line_edit = $LineEdit

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().return_to_main()
		queue_free()
# Called when the node enters the scene tree for the first time.
func _ready():
	button.disabled = true
	line_edit.grab_focus()



func _on_line_edit_text_changed(new_text):
	if not new_text.is_empty():
		button.disabled = false


func _on_line_edit_text_submitted(new_text):
	button.grab_focus()


func _on_button_pressed():
	Globals.player_name = line_edit.text
	get_parent().start_game()
