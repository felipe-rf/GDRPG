extends CharacterBody2D


var target: Vector2 = Vector2(0,0)
var sprite: Texture2D
@onready var sprite_2d = $Sprite2D

@onready var animation_player = $AnimationPlayer
@export var unit_list: Array[PackedScene]
var dead: bool = false


func _on_area_2d_body_entered(body):
	if body is PlayerDungeon and Globals.has_control:
		if not unit_list.is_empty():
			Globals.has_control = false
			get_parent()._start_combat(unit_list)
			dead = true
			get_parent().get_parent().connect("finished",Callable(self,"_on_defeated"))

func _on_defeated():
	self.queue_free()
