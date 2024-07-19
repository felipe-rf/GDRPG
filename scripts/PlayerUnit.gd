extends Unit
class_name PlayerUnit
var unit_portrait:Texture2D

func _initialize(player_character: UnitCharacter) -> void:
	base_stats = player_character.base_stats
	spell_list = player_character.spell_list
	weaknesses = player_character.weaknesses
	resistances = player_character.resistances
	attack_type = player_character.attack_type
	texture = player_character.texture
	animation_type =player_character.animation_type
	unit_portrait = player_character.unit_portrait as Texture2D
	unit_name = player_character.unit_name
	unit_scale = player_character.scale
	if(player_character.stats.is_empty()): 
		stats = player_character.base_stats.duplicate()
	else:
		stats = player_character.stats
	

	sprite.texture = texture
	state = UnitState.Inactive

	scale = scale * unit_scale

func _get_allies(list:Array[Unit]) -> Array[Unit]:
	return list.filter(func(element):return element is PlayerUnit)

func _get_enemies(list:Array[Unit]) -> Array[Unit]:
	return list.filter(func(element):return element is EnemyUnit)

