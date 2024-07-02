extends TextureRect

@export var menu_parent_path: NodePath
@onready var menu_parent = get_node(menu_parent_path)
@onready var menu_timer = $"../menu_timer"

signal item_selected(item)
signal canceled
signal cursor_moved(item)

var disabled = false
var cursor_index : int = 0
var previous_parents: Array[Node]

@export var cursor_offset : Vector2
func _enable():
	cursor_index = 0
	menu_timer.start()
func _process(delta):
	if not disabled:
		if not self.visible: self.visible = true
		var input := Vector2.ZERO
		
		if Input.is_action_just_pressed("ui_up"):
			input.y -= 1
		if Input.is_action_just_pressed("ui_down"):
			input.y += 1
		if Input.is_action_just_pressed("ui_left"):
			input.x -= 1
		if Input.is_action_just_pressed("ui_right"):
			input.x += 1

		if menu_parent is VBoxContainer:
			set_cursor_from_index(cursor_index + input.y)
		elif menu_parent is HBoxContainer:
			set_cursor_from_index(cursor_index + input.x)
		elif menu_parent is GridContainer:
			set_cursor_from_index(cursor_index + input.x + input.y * menu_parent.columns)
		
		if Input.is_action_just_pressed("ui_select"):
			var current_menu_item := get_menu_item_at_index(cursor_index)
			
			if current_menu_item != null:
				if current_menu_item.has_method("cursor_select"):
					emit_signal("item_selected",current_menu_item)
		if Input.is_action_just_pressed("ui_cancel"):
			emit_signal("canceled")
			disabled = true
	else:
		self.visible = false
func get_menu_item_at_index(index : int ) -> Control:
		if menu_parent == null:
			return null
		if index >= menu_parent.get_child_count() or index < 0:
			return null
		return menu_parent.get_child(index) as Control
	
func set_cursor_from_index(index:int) -> void:
	var menu_item := get_menu_item_at_index(index)
	if menu_item == null: return
	
	var menu_position = menu_item.global_position
	var menu_size = menu_item.size

	global_position = Vector2(menu_position.x, menu_position.y + (menu_size.y / 2.0)) - (size / 2.0) - cursor_offset
	cursor_index = index
	emit_signal("cursor_moved",menu_item)

func _set_parent(parent: Control)->void:
	previous_parents.append(menu_parent)
	menu_parent = parent
	cursor_index = 0

func _on_menu_timer_timeout():
	disabled = false
