extends Control

@onready var turn_queue = $"../TurnQueue"
@onready var menu_cursor = $MenuCursor ##Cursor for selecting labels in containers
@onready var unit_cursor = $UnitCursor ##Cursor for selecting units
@onready var main_menu = $Panel/MainMenu
@onready var spell_menu = $Panel/SpellMenu
@onready var panel = $Panel
@onready var spell_panel = $SpellPanel
@onready var spell_label = $SpellPanel/Label
@onready var player_portraits = $PlayerPortraits

var current_round = 0

enum cursorState{
	idle,
	attack,
	spell,
	item
}
var current_spell: Spell
var state = cursorState.idle

##Menu Cursor Functions

func _initialize(unit:Unit) -> void: ##Updates GUI and activates cursor
	_set_player_portraits()
	if unit is PlayerUnit:
		menu_cursor._enable()
	if unit is EnemyUnit:
		menu_cursor._disable()

func _set_player_portraits() -> void: ##Updates the player's portraits
	var index = 0
	for unit in turn_queue.player_list:
		var portrait = player_portraits.get_child(index)
		index += 1
		portrait.texture = unit.unit_portrait
		var label: Label = portrait.get_child(0).get_child(0)
		label.text = "HP:" + str(unit.stats[0]) +"/"+str(unit.base_stats[UnitStats.health])
		portrait.visible = true

func _on_menu_cursor_item_selected(item: MenuItem): ##Called when a menu item is selected
	if(item is SpellLabel):
		if spell_panel.visible: spell_panel.visible = false
		if(turn_queue.active_unit.state == 0):
			menu_cursor._disable()
			state = cursorState.spell
			current_spell = item.spell
			unit_cursor._enable(current_spell.target_type,turn_queue.unit_list,turn_queue.active_unit)
		return
	item.cursor_select()

func _on_attack_cursor_selected() -> void: ##Activates unit cursor to attack
	if(turn_queue.active_unit.state == 0):
		menu_cursor._disable()
		state = cursorState.attack
		unit_cursor._enable(1,turn_queue.unit_list,turn_queue.active_unit)

func _on_spell_cursor_selected() -> void: ##Activates the spell panel for spell selection
	var spell_list = turn_queue.active_unit.spell_list
	if spell_list.size() <= 0: return
	_set_spell_labels(spell_list)
	_set_visible(spell_menu)
	menu_cursor._set_parent(spell_menu)

func _set_spell_labels(spell_list: Array[Spell]) -> void: ##Adds spells to spell_panel
	for i in spell_menu.get_children():
		i.queue_free()
	for i in spell_list:
		var new_panel = SpellLabel.new()
		new_panel._initialize(i)
		spell_menu.add_child(new_panel)

func _set_visible(menu: Control) -> void: ##Shows a panel and hide all other panels
	for i in panel.get_children():
		i.visible = false
	menu.visible = true
	return 
	
func _on_menu_cursor_canceled() -> void: ##Cancels menu selection 
	var parents = menu_cursor.previous_parents
	if menu_cursor.menu_parent == spell_menu:
		if spell_panel.visible: spell_panel.visible = false
		_set_visible(main_menu)
		menu_cursor._set_parent(main_menu)
	menu_cursor._enable()

func _on_menu_cursor_cursor_moved(item) -> void: ##Called when the menu cursor is moved
	if item is SpellLabel:
		if not spell_panel.visible: spell_panel.visible = true
		spell_label.text = item.spell.description

func _on_defend_cursor_selected() -> void: ##Makes unit defend
	menu_cursor._disable()
	turn_queue.active_unit._defend()

func _on_skip_cursor_selected() -> void: ##Skips unit's turn
	menu_cursor._disable()
	turn_queue.active_unit._skip()

## Unit cursor functions

func _on_unit_cursor_selected(target_list:Array[Unit]) -> void: ##Execute action to targets based on state
	if state == cursorState.attack:
		turn_queue.active_unit._attack_unit(target_list[0])
		await turn_queue.active_unit.attackFinished
		state = cursorState.idle
	if state == cursorState.spell:
		turn_queue.active_unit._use_spell(current_spell,target_list)
		await turn_queue.active_unit.attackFinished
		menu_cursor._set_parent(main_menu)
		state = cursorState.idle
		_set_visible(main_menu)

func _on_unit_cursor_canceled() -> void: ##Cancels unit selection
	if state == cursorState.attack:
		menu_cursor._enable()
		state = cursorState.idle
	if state == cursorState.spell:
		menu_cursor._enable()
		state == cursorState.idle
