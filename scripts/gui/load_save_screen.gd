extends Control

@export var save_button: PackedScene
@onready var v_box_container = $ScrollContainer/VBoxContainer
@onready var savestate = $Savestate
var current_save = null
@onready var button = $Button

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_parent().return_to_main()
		queue_free()
# Called when the node enters the scene tree for the first time.
func _ready():
	var button_group = ButtonGroup.new()
	button_group.allow_unpress = true
	var saves = DirAccess.get_files_at("user://")
	for i in 3:
			spawn_button(i,button_group, "manual_save_")
			spawn_button(i,button_group, "auto_")
	button.disabled = true
	if not v_box_container.get_children().is_empty():
		v_box_container.get_child(0).grab_focus()
	else:
		get_parent().return_to_main()
		queue_free()
	

func spawn_button(number,group,type):
		var save_file = type + str(number) + ".sav"
		print(save_file)
		var new_button: Button = save_button.instantiate()
		savestate.save_filename = save_file
		if savestate.save_exists():
			savestate.load_game_state()
			savestate.get_game_variables(SaveManager)
			new_button.text = SaveManager.player_name + is_auto_save(SaveManager.auto_save)+ "\n" + str(SaveManager.save_time)
			new_button.save = save_file
			new_button.button_group = group
			v_box_container.add_child(new_button)
			new_button.connect("_pressed",Callable(self,"select_save"))


func is_auto_save(auto_save):
	if auto_save:
		return " - AutoSave"
	return ""

func select_save(save_button: Button):
	button.disabled = false
	current_save = save_button.save
	


func _on_button_pressed():
	if current_save != null:
		SaveManager.manual_load(savestate,current_save)
