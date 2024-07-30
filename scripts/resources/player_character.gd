extends UnitCharacter
class_name PlayerCharacter

signal experience_gained(growth_data,player)
signal leveled_up(level,next_level,next_health,player)
@export var unit_portrait:Texture2D
@export var unit_picture: Texture2D
var stats: Array[int]

@export var level: int = 1
@export var experience: int
var new_exp: int
var experience_total: int

var exp_required: int = get_required_exp(level+1)

func update(_exp: int, _stats: Array[int]) -> void:
	new_exp = _exp
	stats = _stats.duplicate()
	if stats[0] <= 0:
		stats[0] = 1

func add_spell(spell: Spell) -> void:
	spell_list.append(spell)

func get_required_exp(_level: int):
	return round(pow(_level,1.8) + _level * 4)

func gain_experience(_exp: int= 100) -> void:
	experience_total += _exp
	experience += _exp
	var growth_data = []
	while experience >= exp_required:
		experience -= exp_required
		growth_data.append([exp_required,exp_required])
		level_up()
	growth_data.append([experience,exp_required])
	print(growth_data)
	emit_signal("experience_gained",growth_data,self)
func level_up() -> void:
	var next_health = base_stats[0] + 5
	base_stats[0] = next_health
	emit_signal("leveled_up",level,level+1,next_health,self)
	level +=1
	exp_required = get_required_exp(level+1)

func update_stat(stat:int):
	base_stats[stat] += 1
