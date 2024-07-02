extends Control

@onready var turn_queue = $"../TurnQueue"
@onready var menu_cursor = $MenuCursor
@onready var unit_cursor = $UnitCursor

@onready var main_menu = $Panel/MainMenu
@onready var spell_menu = $Panel/SpellMenu
@onready var panel = $Panel

var current_round = 0

enum cursorState{
	idle,
	attack,
	spell
}
var current_spell: Spell
var state = cursorState.idle

func _on_attack_cursor_selected():
	if(turn_queue.active_unit.state == 0):
		menu_cursor.disabled = true
		state = cursorState.attack
		unit_cursor._enable(1,turn_queue.unit_list,turn_queue.active_unit)

func _set_spell_labels(spell_list: Array[Spell]):
	for i in spell_menu.get_children():
		i.queue_free()
	for i in spell_list:
		var new_panel = SpellLabel.new()
		new_panel._initialize(i)
		spell_menu.add_child(new_panel)
		
func _on_unit_cursor_selected(target_list:Array[Unit]):
	if state == cursorState.attack:
		turn_queue.active_unit._attack_unit(target_list[0])
		menu_cursor._enable()
		state = cursorState.idle
	if state == cursorState.spell:
		turn_queue.active_unit._use_spell(current_spell,target_list)
		menu_cursor._enable()
		menu_cursor._set_parent(main_menu)
		state = cursorState.idle
		_set_visible(main_menu)


func _on_unit_cursor_canceled():
	if state == cursorState.attack:
		menu_cursor._enable()
		state = cursorState.idle
	if state == cursorState.spell:
		menu_cursor._enable()
		state == cursorState.idle


func _on_spell_cursor_selected():
	var spell_list = turn_queue.active_unit.spell_list
	if spell_list.size() <= 0: return
	_set_spell_labels(spell_list)
	_set_visible(spell_menu)
	menu_cursor._set_parent(spell_menu)
	




func _on_menu_cursor_item_selected(item: MenuItem):
	if(item is SpellLabel):
		if(turn_queue.active_unit.state == 0):
			menu_cursor.disabled = true
			state = cursorState.spell
			current_spell = item.spell
			unit_cursor._enable(current_spell.target_type,turn_queue.unit_list,turn_queue.active_unit)
		return
	item.cursor_select()

func _set_visible(menu: Control):
	for i in panel.get_children():
		i.visible = false
	menu.visible = true
	return 
	
func _on_menu_cursor_canceled():
	var parents = menu_cursor.previous_parents
	if menu_cursor.menu_parent == spell_menu:
		_set_visible(main_menu)
		menu_cursor._set_parent(main_menu)
	menu_cursor._enable()
