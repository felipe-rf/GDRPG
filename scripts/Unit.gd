extends Node2D
class_name Unit

@export var base_health:int
@export var base_attack:int
@export var base_speed:int
@export var base_defense:int
@export var base_precision:int
@export var  unit_name: String
var health: int
var attack: int
var speed: int
var defense: int
var precision: int
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



func _activate(unit_list:Array[Unit]):
	state = UnitState.Active
	actions = 1
	_get_allies(unit_list)
	_get_enemies(unit_list)
	
func _deactivate():
	if(state == UnitState.Active):
		state = UnitState.Inactive
		
func _rand10():
	randomize()
	return(randi_range(1,10))
	
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
	else:
		health += base_health -health

func _aplly_stat_change(change,stat: int):
	match stat:
		UnitStats.speed:
			attack *= change

func _miss_attack():
	print("missed")
	
func _attack_unit(target: Unit):
	#Try to hit
	var hit = _rand10()
	if(hit == 1):
		_miss_attack()
	elif(hit+precision<target.speed):
		_miss_attack()
	elif(hit+precision>target.speed):
		print(unit_name + " attacked "+ target.unit_name + " for " + str(attack)+ " damage.")
		target._receive_damage(attack)
	emit_signal("turnEnded")
	_deactivate()
	
