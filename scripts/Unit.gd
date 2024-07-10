extends Node2D
class_name Unit

@export var base_health:int
@export var base_attack:int
@export var base_speed:int
@export var base_defense:int
@export var base_precision:int
@export var base_magic: int
@export var base_strenght: int
@export var unit_name: String
@export var spell_list: Array[Spell]

@export var weaknesses: Array[int]
@export var resistances: Array[int]
@export var attack_type:int = 0

@export var texture:Texture2D

var health: int
var attack: int
var speed: int
var defense: int
var precision: int
var magic: int
var strenght: int

var stat_timer: Array[int] = [0,0,0,0,0,0,0]
var queued_stat_timer: Array[int] = [0,0,0,0,0,0,0]

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var damage_popup = $DamagePopup
@onready var text_popup = $TextPopup
@onready var selected_animation = $SelectedAnimation

@export var animation_type: int


signal turnEnded
signal attackFinished

var state
var actions = 0
enum UnitState{
	Active,
	Inactive,
	Disabled
}





var allies_list:Array[Unit]
var enemies_list:Array[Unit]
		
# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = texture
	state = UnitState.Inactive
	health = base_health
	attack = base_attack
	speed = base_speed
	defense = base_defense
	precision = base_precision
	magic = base_magic
	strenght = base_strenght



func _activate(unit_list:Array[Unit]):
	_select_animation()
	actions = 1
	_get_allies(unit_list)
	_get_enemies(unit_list)
	for i in range(7):
		if(stat_timer[i]>0):
			stat_timer[i] -=1
			if(stat_timer[i] == 0):
				_reset_stat(i)
		else:
			stat_timer[i] = queued_stat_timer[i]
			queued_stat_timer[i] = 0
	state = UnitState.Active
	
func _deactivate():
	if(state == UnitState.Active):
		state = UnitState.Inactive
func _reset_stat(stat: int):
	text_popup.popup(UnitStats.stat_names[stat].capitalize() + " resetted!",2)
	match stat:
		UnitStats.attack:
			attack = base_attack
		UnitStats.speed:
			speed = base_speed
		UnitStats.defense:
			defense = base_defense
		UnitStats.precision:
			precision = base_precision
		UnitStats.strength:
			strenght = base_strenght
		UnitStats.magic:
			magic = base_magic

func _select_animation():
	selected_animation.play("selected")
func _unselect_animation(include_self:bool=true):
	if not include_self:
		if(self.state == UnitState.Active):
			return
	selected_animation.play("unselected")
func _rand20():
	randomize()
	return(randi_range(1,20))
	
func _get_allies(unit_list:Array[Unit]):
	print("This shouldn't happen ;-; ")
	
func _get_enemies(unit_list:Array[Unit]):
	print("This shouldn't happen ;-; ")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(actions<=0):
		_deactivate()




func _receive_damage(damage: int, damage_type: int):
	damage_popup.popup(str(damage),1,damage_type)
	animation_player.animation_set_next("unit/Hurt","unit/Idle")
	animation_player.play("unit/Hurt",-1,2)
	health -= damage
	if(health<=0):
		health = 0
		_die()

func _die():
	print(unit_name + " died!")
	state = UnitState.Disabled
	animation_player.play("unit/Dead")
	
func _receive_healing(heal):
	if((health+heal)<=base_health):
		health += heal
		damage_popup.popup(str(heal),0)
		print(unit_name + " was healed for " + str(heal) + " health points.")
	else:
		health += base_health -health
		damage_popup.popup(str(base_health -health),0)
		print(unit_name + " was healed for " + str(base_health -health) + " health points.")


func _aplly_stat_change(change: int, stat: int, time:int):
	stat_timer[stat] = time
	match stat:
		UnitStats.attack:
			_stat_change_notify(change,base_attack,stat)
			attack = clamp(change,base_attack/2,base_attack*2)

		UnitStats.speed:
			_stat_change_notify(change,base_speed,stat)
			speed = clamp(change,base_speed/2,base_speed*2)
				
		UnitStats.defense:
			_stat_change_notify(change,base_defense,stat)
			defense = clamp(change,base_defense/2,base_defense*2)
		UnitStats.precision:
			_stat_change_notify(change,base_precision,stat)
			precision = clamp(change,base_precision/2,base_precision*2)
				
		UnitStats.strength:
			_stat_change_notify(change,base_strenght,stat)
			strenght = clamp(change,base_strenght/2,base_strenght*2)
				
		UnitStats.magic:
			_stat_change_notify(change,base_magic,stat)
			magic = change
		
	
func _stat_change_notify(change: int, stat_value: int, stat: int):
	if(change>stat_value):
		text_popup.popup(UnitStats.stat_names[stat].capitalize() + " increased!",2)
	elif(change==stat_value):
		text_popup.popup("Nothing happened!",2)
	elif(change<stat_value):
		text_popup.popup(UnitStats.stat_names[stat].capitalize() + " decreased!",2)

	
func _miss_attack():
	text_popup.popup("Missed",2)
	print(unit_name + " missed.")
	
	
func _attack_unit(target: Unit):
	_unselect_animation()
	match animation_type:
		0:
			_attack_animation_move(target)
		1:
			_attack_animation_ranged(target)
	
	
func _attack_animation_move(target:Unit):
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


func _attack_animation_ranged(target: Unit):
	animation_player.animation_set_next("unit/Attack","unit/Idle")
	animation_player.play("unit/Attack")
	await animation_player.attack_hit
	_deal_attack_damage(target)
	await animation_player.animation_changed
	emit_signal("attackFinished")
	_end_turn()
	
func _deal_attack_damage(target: Unit):
	var hit = _rand20()
	var dmg = randi_range(1,attack) + strenght
	if(hit == 1):
		_miss_attack()
	elif(hit+precision<target.speed+target.defense):
		_miss_attack()
	elif(hit+precision>target.speed+target.defense):
		dmg = target._aplly_weakness_and_resistance(dmg,attack_type)
		print(unit_name + " attacked "+ target.unit_name + " for " + str(dmg)+ " damage.")
		target._receive_damage(dmg,attack_type)

func _play_turn():
	return

func _end_turn():
	emit_signal("turnEnded")
	_deactivate()
	_unselect_animation()

func _use_spell(spell: Spell, target_list: Array[Unit]):
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

	

func _aplly_weakness_and_resistance(damage: int, type: int) -> int:
	if weaknesses.has(type):
		text_popup.popup("Weak!",2)
		return damage * 2
	elif resistances.has(type):
		text_popup.popup("Resisted",2)
		return damage/2
	else: return damage

func _defend():
	_unselect_animation()
	_aplly_stat_change(defense*2,UnitStats.defense,1)
	text_popup.popup("Defended",2)
	_end_turn()
	
func _skip():
	text_popup.popup("Skipped",2)
	_end_turn()
