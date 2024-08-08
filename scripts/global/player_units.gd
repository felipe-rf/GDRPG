extends Node


func get_player_list() -> Array[PlayerCharacter]:
	var list = get_children().filter(func(element): return element is PlayerCharacter)
	var _list: Array[PlayerCharacter]
	_list.assign(list)
	return _list 
