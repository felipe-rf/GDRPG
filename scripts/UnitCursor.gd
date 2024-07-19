extends TextureRect



@onready var unit_timer = $"../unit_timer"

signal selected(target_list: Array[Unit])
signal canceled

var unit_list: Array[Unit]
var disabled = true
var target_type
var cursor_index : int = 0
var area_list:Array
@export var cursor_offset : Vector2

func _erase_areas()->void:
	for i in area_list:
		i.queue_free()
		area_list.erase(i)

func _enable(type: int, list: Array[Unit], current_unit: Unit) -> void:
	_erase_areas()
	unit_timer.start()
	target_type = type
	match type:
		EffectTargets.SINGLE_ALLY:
			unit_list = list.filter(func(element): return element is PlayerUnit)
		EffectTargets.SINGLE_ENEMY:
			unit_list = list.filter(func(element): return element is EnemyUnit)
		EffectTargets.ALL_ENEMIES:
			unit_list = list.filter(func(element): return element is EnemyUnit)
		EffectTargets.ALL_ALLIES:
			unit_list = list.filter(func(element): return element is PlayerUnit)
		EffectTargets.SELF:
			unit_list = [current_unit]
	for i in unit_list:
		var area = UnitArea.new()
		i.add_child(area)
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = i.sprite.get_rect().size
		collision.shape = shape
		area.add_child(collision)
		area.connect("_mouse_entered",Callable(self,"set_cursor_from_mouse"))
		area_list.append(area)

func _process(delta) -> void:
	if not disabled:
		if not self.visible: self.visible = true
		if(target_type == EffectTargets.SINGLE_ALLY or target_type == EffectTargets.SINGLE_ENEMY):
			single_target_select()
		else:
			multiple_target_select()
	else:
		#_erase_areas()
		self.visible = false
		cursor_index = 0

func get_menu_item_at_index(index : int ) -> Unit:
		if index >= unit_list.size() or index < 0:
			return null
		return unit_list[index]	

func set_cursor_from_index(index:int) -> void:

	var menu_item = get_menu_item_at_index(index)
	if menu_item == null: return
	
	var menu_position = menu_item.sprite.global_position
	var menu_size = menu_item.sprite.get_rect().size*menu_item.unit_scale

	global_position = Vector2(menu_position.x+10, menu_position.y-50) - cursor_offset
	cursor_index = index

func set_cursor_from_mouse(area) -> void:
	var menu_item = area.get_parent()
	if menu_item == null: return
	
	var menu_position = menu_item.sprite.global_position
	var menu_size = menu_item.sprite.get_rect().size*menu_item.unit_scale

	global_position = Vector2(menu_position.x+10, menu_position.y-50) - cursor_offset
	cursor_index = unit_list.find(menu_item)

func single_target_select() -> void:
	var input := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		input.y -= 1
	if Input.is_action_just_pressed("ui_down"):
		input.y += 1
	if Input.is_action_just_pressed("ui_left"):
		input.x -= 1
	if Input.is_action_just_pressed("ui_right"):
		input.x += 1
		
	set_cursor_from_index(cursor_index + input.x + input.y * (unit_list.size()/2))
	
	if Input.is_action_just_pressed("ui_select") or Input.is_mouse_button_pressed(1):
		var current_menu_item: Array[Unit] = [get_menu_item_at_index(cursor_index)]
		if current_menu_item != null:
			_erase_areas()
			emit_signal("selected",current_menu_item)
			disabled = true
			
	if Input.is_action_just_pressed("ui_cancel")or Input.is_mouse_button_pressed(2):
		_erase_areas()
		emit_signal("canceled")
		disabled = true

func multiple_target_select() -> void:
	_erase_areas()
	self.visible = false
	#set_cursor_from_index(0)
	for unit in unit_list:
		if(unit != null): unit._select_animation()
	if Input.is_action_just_pressed("ui_select") or Input.is_mouse_button_pressed(1):
		var current_menu_item = unit_list
		if current_menu_item != null:
			for unit in unit_list:
				unit._unselect_animation(false)
			emit_signal("selected",current_menu_item)
			disabled = true
			
	if Input.is_action_just_pressed("ui_cancel")or Input.is_mouse_button_pressed(2):
		for unit in unit_list:
			if(unit != null): unit._unselect_animation(false)
		emit_signal("canceled")
		disabled = true

func _on_unit_timer_timeout() -> void:
	disabled = false
