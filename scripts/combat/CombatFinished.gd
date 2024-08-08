extends Node2D
class_name FinishedScreen

@export var player_list: Array[PlayerCharacter]
@onready var hbox = $Control/HBox
var panels
var current_player = 0
signal progress_finished
signal update_finished
# Called when the node enters the scene tree for the first time.
@onready var buttons = $Control/Panel/Buttons
@onready var stat_label = $Control/Panel/StatLabel
var players_leveling: Array
@onready var panel = $Control/Panel
@onready var animation_player = $AnimationPlayer
@onready var transition_animation = $"../AnimationPlayer"
@onready var confirm_button = $Control/Panel/ConfirmButton
@onready var update_timer = $UpdateTimer
@onready var continue_button = $Control/ContinueButton
var dungeon_map: PackedScene
var exp = 0
var chosen_stat = 6

func _initialize(players: Array[PlayerCharacter],_exp: int):
	player_list = players
	exp = _exp

func _ready():
	panels = hbox.get_children()
	for i in player_list.size():
		panels[i].get_node("TextureRect").texture = player_list[i].unit_picture
		initialize_panel(i,player_list[i].experience,player_list[i].exp_required)
		player_list[i].connect("experience_gained",Callable(self,"_on_character_exp_gained"))
		player_list[i].connect("leveled_up",Callable(self,"_on_character_leveled_up"))
		
	await transition_animation.animation_finished
	animation_player.play("Start")
	await animation_player.animation_finished
	for i in player_list:
		if i.stats[0] > 0:
			i.gain_experience(exp)
		else:
			i.gain_experience(exp/2)

	for i in buttons.get_children():
		i.connect("toggled_on",Callable(self,"choose_stat"))
	await update_timer.timeout
	if(players_leveling.size() >0):
		for i in players_leveling:
			update_panel(i[0],i[1],i[2])
			choose_stat(6)
			show_panel()
			await confirm_button.pressed
			hide_panel()
	continue_button.visible = true
	continue_button.disabled = false
	continue_button.grab_focus()
func choose_stat(stat: int):
	chosen_stat = stat
	var player_stat = player_list[current_player].base_stats[stat]
	stat_label.text = UnitStats.stat_names[stat].to_upper() + ": " + str(player_stat) + " -> " + str(player_stat + 1)

func update_panel(player_index: int,level,next_health):
	var player = player_list[player_index]
	current_player = player_index
	panel.get_node("TextureRect").texture = player.unit_picture
	panel.get_node("Name").text = player.unit_name
	panel.get_node("Label").text = "LEVELED UP TO LEVEL " + str(level) +"!"
	panel.get_node("MaxHealth"). text = "MAX HEALTH UPGRADED TO: " + str(next_health)
	
func show_panel():
	animation_player.play('PanelShow')
	panel.visible = true
	await animation_player.animation_finished
	buttons.get_child(0).grab_focus()
	buttons.get_child(0).button_pressed = true

func hide_panel():
	animation_player.play('PanelShow',-1,-1,)
	await animation_player.animation_finished
	for i in buttons.get_children():
		i.release_focus()

	
func initialize_panel(index: int,current:int,maximum: int):
	panels[index].visible = true
	var progress_bar: ProgressBar = panels[index].get_node("ProgressBar")
	progress_bar.max_value = maximum
	progress_bar.value = current


func _on_character_leveled_up(_level,next_level,next_health,player):
	players_leveling.append([player_list.find(player),next_level,next_health])

func _on_character_exp_gained(growth_data,player):
	var index = player_list.find(player)
	var progress_bar: ProgressBar = panels[index].get_node("ProgressBar")
	for line in growth_data:
		var target_exp = line[0]
		var max_exp = line[1]
		progress_bar.max_value = max_exp
		await animate_value(target_exp,progress_bar)
		if growth_data.size() > 1:
			panels[index].get_node("Label").visible = true
		if abs(progress_bar.max_value - progress_bar.value) < 0.01:
			progress_bar.value = progress_bar.min_value
		update_timer.start(1.1)
	
func animate_value(target,progress_bar: ProgressBar, tween_duration := 1.0):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(progress_bar,"value",target,tween_duration)
	await tween.finished

		


func _on_confirm_button_pressed():
	player_list[current_player].update_stat(chosen_stat)


func _on_continue_button_pressed():
	transition_animation.play("Transition_out")
	await transition_animation.animation_finished
	get_parent()._return_to_dungeon(player_list,self)


