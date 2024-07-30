extends Node
class_name UnitCharacter

@export var base_stats: Array[int] ##Default stats for unit
@export var spell_list: Array[Spell] 
@export var weaknesses: Array[int] ##Unit's weaknesses
@export var resistances: Array[int] ##Unit's resistances
@export var attack_type:int = 0 ##Unit's default attack's damage type
@export var texture:Texture2D ##Unit's sprite
@export var animation_type: int ##0 for melee attack, 1 for ranged
@export var unit_name: String
@export var scale:int=1
@export var _exp = 0
