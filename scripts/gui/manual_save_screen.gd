extends Control

@export var save_button: PackedScene
@onready var v_box_container = $ScrollContainer/VBoxContainer
@onready var savestate = $Savestate
var current_save = null
@onready var button = $Button
@onready var confirmation_dialog = $ConfirmationDialog
var current_button: Button
signal save_finished(parent)
@onready var timer = $Timer

func _input(event):
	if event is InputEventKey:
		if event.key_label == 4194305:
			_on_timer_timeout()
# Called when the node enters the scene tree for the first time.
func _ready():
	var button_group = ButtonGroup.new()
	button_group.allow_unpress = true
	var buttons = v_box_container.get_children()
	for i in buttons.size():
		set_button(button_group,buttons[i])
	button.disabled = true
	v_box_container.get_child(0).grab_focus()
	

func set_button(group,_button):
		savestate.save_filename = _button.save
		if savestate.save_exists():
			savestate.load_game_state()
			savestate.get_game_variables(SaveManager)
			_button.text = SaveManager.player_name + "\n" + str(SaveManager.save_time)
		else:
			_button.text = "New Save"
		savestate.save_filename = SaveManager.last_save_file
		savestate.load_game_state()
		savestate.set_game_variables(SaveManager)
		_button.button_group = group
		_button.connect("_pressed",Callable(self,"select_save"))

func get_date(file):
	savestate.save_filename = file
	savestate.load_game_state()
	savestate.get_game_variables(SaveManager)
	print(SaveManager.save_time)
	return SaveManager.save_time

func select_save(save_button: Button):
	button.disabled = false
	current_save = save_button.save
	current_button = save_button
	

func _on_button_pressed(): 
	savestate.save_filename = current_save
	if savestate.save_exists():
		confirmation_dialog.visible = true
	else:
		_save()

func _on_confirmation_dialog_confirmed():
	_save()

func disable_all_buttons():
	var buttons = v_box_container.get_children()
	for i in buttons:
		i.disabled = true
	button.disabled = true
	button.text = "SAVED"
	
func _save():
	disable_all_buttons()
	Globals.current_save = current_button.save_number
	SaveManager.manual_save(savestate,get_parent().get_parent(),current_save)
	set_button(current_button.button_group,current_button)
	timer.start()


func _on_timer_timeout():
	emit_signal("save_finished",self)
