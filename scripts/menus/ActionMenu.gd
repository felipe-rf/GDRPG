extends Control

@onready var turn_queue = $"../TurnQueue"
@onready var menu_cursor = $MenuCursor
@onready var unit_cursor = $UnitCursor



func _on_attack_cursor_selected():
	if(turn_queue.active_unit.state == 0):
		menu_cursor.disabled = true
		unit_cursor._enable(1,turn_queue.unit_list)


func _on_unit_cursor_selected(target:Unit):
	turn_queue.active_unit._attack_unit(target)
	menu_cursor._enable()


func _on_unit_cursor_canceled():
	menu_cursor._enable()
