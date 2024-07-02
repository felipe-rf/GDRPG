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

signal turnEnded

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
	state = UnitState.Inactive
	health = base_health
	attack = base_attack
	speed = base_speed
	defense = base_defense
	precision = base_precision
	magic = base_magic
	strenght = base_strenght



func _activate(unit_list:Array[Unit]):
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
	match stat:
		UnitStats.attack:
			attack = base_attack
		UnitStats.speed:
			speed = base_speed
		UnitStats.defense:
			defense = base_defense
		UnitStats.precision:
			precision = base_precision
		UnitStats.strenght:
			strenght = base_strenght
		UnitStats.magic:
			magic = base_magic

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


func _receive_damage(damage):
	health -= damage
	if(health<=0):
		health = 0
		_die()

func _die():
	print(unit_name + " died!")
	state = UnitState.Disabled
	sprite.visible = false
	
func _receive_healing(heal):
	if((health+heal)<=base_health):
		health += heal
		print(unit_name + " was healed for " + str(heal) + " health points.")
	else:
		health += base_health -health
		print(unit_name + " was healed for " + str(base_health -health) + " health points.")


func _aplly_stat_change(change: int, stat: int, time:int):
	queued_stat_timer[stat] = time
	match stat:
		UnitStats.attack:
			if attack == base_attack:
				attack = change
		UnitStats.speed:
			if speed == base_speed:
				speed = change
		UnitStats.defense:
			if defense == base_defense:
				defense = change
		UnitStats.precision:
			if precision == base_precision:
				precision = change
		UnitStats.strenght:
			if strenght == base_strenght:
				strenght = change
		UnitStats.magic:
			if magic == base_magic:
				magic = change

func _miss_attack():
	print(unit_name + " missed.")
	
func _attack_unit(target: Unit):
	#Try to hit
	var hit = _rand20()
	var dmg = randi_range(1,attack) + strenght
	if(hit == 1):
		_miss_attack()
	elif(hit+precision<target.speed+target.defense):
		_miss_attack()
	elif(hit+precision>target.speed+target.defense):
		print(unit_name + " attacked "+ target.unit_name + " for " + str(dmg)+ " damage.")
		target._receive_damage(dmg)
	_end_turn()
	
func _end_turn():
	emit_signal("turnEnded")
	_deactivate()

func _use_spell(spell: Spell, target_list: Array[Unit]):
	print(unit_name + " used " + spell.spell_name +".")
	spell._spell_effect(self,target_list)
	_end_turn()
