extends Node2D
class_name Unit

var base_stats: Array[int] ##Default stats for unit
var spell_list: Array[Spell] 
var weaknesses: Array[int] ##Unit's weaknesses
var resistances: Array[int] ##Unit's resistances
var attack_type:int = 0 ##Unit's default attack's damage type
var texture:Texture2D ##Unit's sprite
var animation_type: int ##0 for melee attack, 1 for ranged

var stats: Array[int] ##Unit stats during combat
var unit_name
var unit_scale: int=1

var _exp = 0

var stat_timer: Array[int] = [0,0,0,0,0,0,0] ##Timer for each one of the unit's stats
var queued_stat_timer: Array[int] = [0,0,0,0,0,0,0] ##Used for starting stat_timer only on unit's turn

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var damage_popup = $DamagePopup
@onready var text_popup = $TextPopup
@onready var selected_animation = $SelectedAnimation
@onready var shadow = $Shadow


signal turnEnded ##Unit ended it's turn and deactivated
signal attackFinished ##Unit finished it's attack animation

var state ##Current state of the unit
var actions = 0 ##Number of actions a unit has per turn

enum UnitState{
	Active, ##Unit is the current unit in turn_queue
	Inactive, ##Unit is waiting for its turn
	Disabled ##Unit is dead
}
var allies_list:Array[Unit] ##All allies in combat
var enemies_list:Array[Unit] ##All enemies in combat
		

func _initialize(unit_character: UnitCharacter) -> void: ##Initializes unit based on UnitCharacter resource
	base_stats = unit_character.base_stats
	spell_list = unit_character.spell_list
	weaknesses = unit_character.weaknesses
	resistances = unit_character.resistances
	attack_type = unit_character.attack_type
	texture = unit_character.texture
	animation_type = unit_character.animation_type
	unit_name = unit_character.unit_name
	unit_scale = unit_character.scale
	
	sprite.texture = texture
	state = UnitState.Inactive
	stats = base_stats.duplicate()
	scale = scale*unit_scale
	_exp = unit_character._exp


func _activate(unit_list:Array[Unit]) -> void: ##Activates unit in its turn.
	_select_animation()
	actions = 1
	allies_list = _get_allies(unit_list)
	enemies_list = _get_enemies(unit_list)
	##Advances stat timer
	for i in range(7):
		if(stat_timer[i]>0):
			stat_timer[i] -=1
			if(stat_timer[i] == 0):
				_reset_stat(i)
		else:
			stat_timer[i] = queued_stat_timer[i]
			queued_stat_timer[i] = 0
	state = UnitState.Active
	
func _deactivate() -> void:##Deactivates Unit
	if(state == UnitState.Active):
		state = UnitState.Inactive
		
func _reset_stat(stat: int) -> void: ##Reset stat to the base value
	text_popup.popup(UnitStats.stat_names[stat].capitalize() + " resetted!",2)
	stats[stat] = base_stats[stat]

func _select_animation() -> void: ##Play selected animation
	selected_animation.play("selected")

func _unselect_animation(include_self:bool=true) -> void: ##Stops selected animation
	if not include_self:
		if(self.state == UnitState.Active):
			return
	selected_animation.play("unselected")

func _rand20() -> int: ##Generates number between 1 and 20
	randomize()
	return(randi_range(1,20))
	
func _get_allies(_unit_list:Array[Unit]) -> Array[Unit]: ##Returns all of unit's allies
	print("This shouldn't happen ;-; ")
	return []
	
func _get_enemies(_unit_list:Array[Unit]) -> Array[Unit]: ##Return all of unit's enemies
	print("This shouldn't happen ;-; ")
	return []
	
func _process(_delta) -> void: ## Called every frame. 'delta' is the elapsed time since the previous frame.
	shadow.texture = sprite.texture 
	shadow.frame = sprite.frame
	if(actions<=0):
		_deactivate()
	
func _receive_damage(damage: int, damage_type: int) -> void: ##Receives damage and checks for death
	damage_popup.popup(str(damage),1,damage_type)
	animation_player.animation_set_next("unit/Hurt","unit/Idle")
	animation_player.play("unit/Hurt",-1,2)
	stats[UnitStats.health] -= damage
	if(stats[UnitStats.health]<=0):
		stats[UnitStats.health] = 0
		_die()

func _die() -> void: ##Disables the unit
	print(unit_name + " died!")
	state = UnitState.Disabled
	if self is EnemyUnit:
		get_parent()._add_exp(_exp)
	animation_player.play("unit/Dead")
	
func _receive_healing(heal) -> void: ##Adds healing to health
	if((stats[UnitStats.health]+heal)<=base_stats[UnitStats.health]):
		stats[UnitStats.health] += heal
		damage_popup.popup(str(heal),0)
		print(unit_name + " was healed for " + str(heal) + " health points.")
	else:
		stats[UnitStats.health] += base_stats[UnitStats.health] - stats[UnitStats.health]
		damage_popup.popup(str(base_stats[UnitStats.health] -stats[UnitStats.health]),0)
		print(unit_name + " was healed for " + str(base_stats[UnitStats.health] -stats[UnitStats.health]) + " health points.")

func _aplly_stat_change(change: int, stat: int, time:int) -> void: ##Changes stat temporarily
	stat_timer[stat] = time
	_stat_change_notify(change,stats[stat],stat)
	stats[stat] = clamp(change,base_stats[stat]/2,base_stats[stat]*2)

func _stat_change_notify(change: int, stat_value: int, stat: int) -> void: ##Popup notification of stat change
	if(change>stat_value):
		text_popup.popup(UnitStats.stat_names[stat].capitalize() + " increased!",2)
	elif(change==stat_value):
		text_popup.popup("Nothing happened!",2)
	elif(change<stat_value):
		text_popup.popup(UnitStats.stat_names[stat].capitalize() + " decreased!",2)

func _miss_attack() -> void: ##Misses attack :(
	text_popup.popup("Missed",2)
	print(unit_name + " missed.")

func _attack_unit(target: Unit) -> void: ##Attacks the target unit
	_unselect_animation()
	match animation_type:
		0:
			_attack_animation_move(target)
		1:
			_attack_animation_ranged(target)

func _attack_animation_move(target:Unit) -> void: ##Animation for melee attack
	var original_position = global_position
	var original_z = z_index
	z_index = target.z_index+1
	var move_tween = create_tween()
	var target_size = target.sprite.get_rect().size
	var target_offset = Vector2(target_size.x*1.5,0)
	if self is EnemyUnit: target_offset = Vector2(-target_offset.x,target.sprite.offset.y)
	move_tween.tween_property(self,"global_position",target.global_position-target_offset,1)
	move_tween.tween_property(self,"global_position",original_position,0.5)
	animation_player.play("unit/Move")
	await move_tween.step_finished
	move_tween.pause()
	animation_player.play("unit/Attack")
	await animation_player.attack_hit
	_deal_attack_damage(target)
	await animation_player.animation_finished
	move_tween.play()
	animation_player.play("unit/Move")
	await move_tween.finished
	z_index = original_z
	animation_player.play("unit/Idle")
	emit_signal("attackFinished")
	_end_turn()

func _attack_animation_ranged(target: Unit) -> void: ##Animation for ranged attack
	animation_player.animation_set_next("unit/Attack","unit/Idle")
	animation_player.play("unit/Attack")
	await animation_player.attack_hit
	_deal_attack_damage(target)
	await animation_player.animation_changed
	emit_signal("attackFinished")
	_end_turn()

func _deal_attack_damage(target: Unit) -> void: ##Calculates and deals the attack damage to target
	var hit = _rand20()
	var dmg = randi_range(1,stats[UnitStats.attack]) + stats[UnitStats.strength]
	if(hit <= 1):
		target._miss_attack()
	elif(hit+stats[UnitStats.precision]<target.stats[UnitStats.speed]+target.stats[UnitStats.defense]):
		target._miss_attack()
	elif(hit+stats[UnitStats.precision]>=target.stats[UnitStats.speed]+target.stats[UnitStats.defense]):
		dmg = target._aplly_weakness_and_resistance(dmg,attack_type)
		print(unit_name + " attacked "+ target.unit_name + " for " + str(dmg)+ " damage.")
		target._receive_damage(dmg,attack_type)

func _play_turn() -> void: ##Unit plays its turn
	return

func _end_turn() -> void: ##Unit ends its turn
	emit_signal("turnEnded")
	_deactivate()
	_unselect_animation()

func _use_spell(spell: Spell, target_list: Array[Unit]) -> void: ##Casts the spell on target(s)
	_unselect_animation()
	animation_player.animation_set_next("unit/UseSpell","unit/Idle")
	animation_player.play("unit/UseSpell")
	text_popup.popup("Used " + spell.spell_name,2)
	await animation_player.attack_hit
	spell._spell_effect(self,target_list)
	await animation_player.animation_changed
	print(unit_name + " used " + spell.spell_name +".")
	emit_signal("attackFinished")
	_end_turn()


func _use_item(item: Item, target_list: Array[Unit], inventory: PlayerInventory) -> void: ##Casts the spell on target(s)
	_unselect_animation()
	animation_player.animation_set_next("unit/UseSpell","unit/Idle")
	animation_player.play("unit/UseSpell")
	text_popup.popup("Used " + item.item_name,2)
	await animation_player.attack_hit
	item._item_effect(self,target_list)
	inventory._use_item(item)
	await animation_player.animation_changed
	print(unit_name + " used " + item.item_name +".")
	emit_signal("attackFinished")
	_end_turn()


func _calc_spell_hit(target: Unit) -> bool: ##Returns whether the spell hit or not
	var hit = _rand20()
	if(hit == 1):
		target._miss_attack()
		return false
	elif(hit+stats[UnitStats.precision]<target.stats[UnitStats.speed]):
		target._miss_attack()
		return false
	elif(hit+stats[UnitStats.precision]>target.stats[UnitStats.speed]):
		return true
	return false

func _aplly_weakness_and_resistance(damage: int, type: int) -> int: ##Changes damage received according to weaknesses/resistances
	if weaknesses.has(type):
		text_popup.popup("Weak!",2)
		return damage * 2
	elif resistances.has(type):
		text_popup.popup("Resisted",2)
		return damage/2
	else: return damage

func _defend(): ##Doubles defense and skips turn
	_unselect_animation()
	_aplly_stat_change(stats[UnitStats.defense]*2,UnitStats.defense,1)
	text_popup.popup("Defended",2)
	_end_turn()
	
func _skip(): ##Skips turn
	text_popup.popup("Skipped",2)
	_end_turn()
