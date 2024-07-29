extends CharacterBody2D
class_name PlayerFollower

@onready var navigation_agent_2d = $NavigationAgent2D

var target: Vector2 = Vector2(0,0)
var sprite: Texture2D
@onready var sprite_2d = $Sprite2D

@onready var animation_player = $AnimationPlayer



func _physics_process(delta):
	sprite_2d.texture = sprite
	velocity = lerp(global_position,target,50)
	if velocity.length() > 0.01:
		animation_player.play("Move")
	else:
		animation_player.play("Idle")
	if global_position.direction_to(get_parent().global_position).x >= 0:
		sprite_2d.flip_h = false
	elif global_position.direction_to(get_parent().global_position).x < 0:
		sprite_2d.flip_h = true
		
	move_and_slide()
