extends Control

@onready var turn_queue = $"../TurnQueue"

@onready var unit_cursor = $UnitCursor ##Cursor for selecting units
@onready var main_menu = $Panel/MainMenu
@onready var spell_menu = $Panel/SpellMenu
@onready var panel = $Panel
@onready var spell_panel = $SpellPanel
@onready var spell_label = $SpellPanel/Label
@onready var player_portraits = $PlayerPortraits
@onready var item_menu = $Panel/ScrollContainer/ItemMenu
@onready var combat_scene = $".."

var current_round = 0
var current_grid
enum cursorState{
	idle,
	attack,
	spell,
	item
}
var current_spell: Spell
var current_item: Item
var state = cursorState.idle

var current_container: Container

func _input(event):
	if event is InputEventKey:
		if event.key_label == 4194305:
			if unit_cursor.disabled == false:
				return
			_on_menu_cursor_canceled()
	if event is InputEventMouseButton:
		if event.button_index == 2:
			if unit_cursor.disabled == false:
				return
			_on_menu_cursor_canceled()
##Menu Cursor Functions

func _initialize(unit:Unit) -> void: ##Updates GUI and activates cursor
	_set_player_portraits()
	if spell_panel.visible: spell_panel.visible = false
	if unit is PlayerUnit:
		current_container = main_menu
		_enable_buttons(main_menu)
	if unit is EnemyUnit:
		_disable_buttons(main_menu)

func _set_player_portraits() -> void: ##Updates the player's portraits
	var index = 0
	for unit in turn_queue.player_list:
		var portrait = player_portraits.get_child(index)
		index += 1
		portrait.texture = unit.unit_portrait
		var label: Label = portrait.get_child(0).get_child(0)
		label.text = "HP:" + str(unit.stats[0]) +"/"+str(unit.base_stats[UnitStats.health])
		portrait.visible = true

func _on_attack_cursor_selected() -> void: ##Activates unit cursor to attack
	if(turn_queue.active_unit.state == 0):
		_disable_buttons(main_menu)
		state = cursorState.attack
		unit_cursor._enable(1,turn_queue.unit_list,turn_queue.active_unit)
		
func _on_spell_cursor_selected() -> void: ##Activates the spell menu for spell selection
	var spell_list = turn_queue.active_unit.spell_list
	if spell_list.size() <= 0: return
	_set_spell_labels(spell_list)
	_set_visible(spell_menu)
	_enable_buttons(spell_menu)
	#spell_menu.get_child(0).grab_focus()

func _on_item_cursor_selected(): ##Activates the item menu for item selection
	var item_list = combat_scene.player_inventory.inventory
	if item_list.size() <= 0: return
	_set_item_labels(item_list)
	
	_set_visible(item_menu)
	item_menu.get_parent().visible = true
	_enable_buttons(item_menu)

func _set_spell_labels(spell_list: Array[Spell]) -> void: ##Adds spells to spell_menu
	for i in spell_menu.get_children():
		i.queue_free()
	for i in spell_list:
		var new_panel = SpellButton.new()
		new_panel._initialize(i)
		spell_menu.add_child(new_panel)
		new_panel.theme = self.theme
		new_panel.connect("_pressed",Callable(self,"_spell_button_pressed"))
		new_panel.connect("_focused",Callable(self,"_on_menu_cursor_cursor_moved"))
		
func _set_item_labels(item_list: Array[Item]) -> void: ##Adds items to item_menu
	for i in item_menu.get_children():
		i.queue_free()
	for i in item_list:
		var new_panel = ItemButton.new()
		new_panel._initialize(i)
		item_menu.add_child(new_panel)
		new_panel.theme = self.theme
		new_panel.connect("_pressed",Callable(self,"_item_button_pressed"))
		new_panel.connect("_focused",Callable(self,"_on_menu_cursor_cursor_moved"))
		
func _set_visible(menu: Control) -> void: ##Shows a panel and hide all other panels
	for i in panel.get_children():
		i.visible = false
	menu.visible = true
	current_container = menu
	return 
	
func _on_menu_cursor_canceled() -> void: ##Cancels menu selection 
	unit_cursor._erase_areas()
	if current_container == spell_menu:
		if spell_panel.visible: spell_panel.visible = false
		_set_visible(main_menu)
		for i in spell_menu.get_children():
			i.queue_free()
	if current_container == item_menu:
		_set_visible(main_menu)
		for i in item_menu.get_children():
			i.queue_free()
	_enable_buttons(main_menu)

func _on_menu_cursor_cursor_moved(item) -> void: ##Called when the menu cursor is moved
	if item is SpellButton and item.disabled == false:
		if not spell_panel.visible: spell_panel.visible = true
		spell_label.text = item.spell.description

func _on_defend_cursor_selected() -> void: ##Makes unit defend
	_disable_buttons(main_menu)
	turn_queue.active_unit._defend()

func _on_skip_cursor_selected() -> void: ##Skips unit's turn
	turn_queue.active_unit._skip()

func _spell_button_pressed(item) -> void: ##Executes the selected spell
	if spell_panel.visible: spell_panel.visible = false
	if(turn_queue.active_unit.state == 0):
		_disable_buttons(spell_menu)
		state = cursorState.spell
		current_spell = item.spell
		unit_cursor._enable(current_spell.target_type,turn_queue.unit_list,turn_queue.active_unit)

func _item_button_pressed(item) -> void: ##Executes the selected item
	if(turn_queue.active_unit.state == 0):
		_disable_buttons(item_menu)
		state = cursorState.item
		current_item = item.item
		unit_cursor._enable(current_item.target_type,turn_queue.unit_list,turn_queue.active_unit)
	
func _disable_buttons(grid: Container): ##Disables all buttons on a container
	for i in grid.get_children():
		i.disabled = true
		i.release_focus()
	
func _enable_buttons(grid: Container): ##Enables all buttons on a container
	for i in grid.get_children():
		i.disabled = false
	grid.get_child(0).grab_focus()
## Unit cursor functions

func _on_unit_cursor_selected(target_list:Array[Unit]) -> void: ##Execute action to targets based on state
	if state == cursorState.attack:
		turn_queue.active_unit._attack_unit(target_list[0])
		await turn_queue.active_unit.attackFinished
		state = cursorState.idle
	if state == cursorState.spell:
		turn_queue.active_unit._use_spell(current_spell,target_list)
		await turn_queue.active_unit.attackFinished
		_enable_buttons(current_container)
		state = cursorState.idle
		_set_visible(main_menu)
	if state == cursorState.item:
		turn_queue.active_unit._use_item(current_item,target_list,combat_scene.player_inventory)
		await turn_queue.active_unit.attackFinished
		_enable_buttons(current_container)
		state = cursorState.idle
		_set_visible(main_menu)

func _on_unit_cursor_canceled() -> void: ##Cancels unit selection
	unit_cursor.disabled = true
	if state == cursorState.attack:
		_enable_buttons(current_container)
		state = cursorState.idle
	if state == cursorState.spell:
		_enable_buttons(current_container)
		state == cursorState.idle
