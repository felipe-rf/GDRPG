extends TextureRect

@onready var unit_timer = $"../unit_timer"

signal selected(target_list: Array[Unit])
signal canceled

var unit_list: Array[Unit]
var disabled = true
var target_type
func _enable(type: int, list: Array[Unit], current_unit: Unit):
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

var cursor_index : int = 0
@export var cursor_offset : Vector2
func _process(delta):
	if not disabled:
		if not self.visible: self.visible = true
		if(target_type == EffectTargets.SINGLE_ALLY or target_type == EffectTargets.SINGLE_ENEMY):
			single_target_select()
		else:
			multiple_target_select()
	else:
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
	var menu_size = menu_item.sprite.get_rect().size*menu_item.scale

	global_position = Vector2(menu_position.x+10, menu_position.y-50) - cursor_offset
	cursor_index = index

func single_target_select():
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
	
	if Input.is_action_just_pressed("ui_select"):
		var current_menu_item: Array[Unit] = [get_menu_item_at_index(cursor_index)]
		if current_menu_item != null:
			emit_signal("selected",current_menu_item)
			disabled = true
			
	if Input.is_action_just_pressed("ui_cancel"):
		emit_signal("canceled")
		disabled = true

func multiple_target_select():
	set_cursor_from_index(0)
	for unit in unit_list:
		if(unit != null): unit._select_animation()
	if Input.is_action_just_pressed("ui_select"):
		var current_menu_item = unit_list
		if current_menu_item != null:
			for unit in unit_list:
				unit._unselect_animation(false)
			emit_signal("selected",current_menu_item)
			disabled = true
			
	if Input.is_action_just_pressed("ui_cancel"):
		for unit in unit_list:
			if(unit != null): unit._unselect_animation(false)
		emit_signal("canceled")
		disabled = true
		
func _on_unit_timer_timeout():
	disabled = false
