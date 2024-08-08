extends CharacterBody2D
class_name PlayerDungeon

@onready var raycast = $RayCast2D

@export var player_follower: PackedScene
@export var max_speed: int
@export var acc: int
@export var fric: int
# Called when the node enters the scene tree for the first time.
var input_vector:Vector2
var velo:Vector2
@onready var line_2d = $Line2D
@onready var timer = $Timer

@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
var follower_list: Array[PlayerFollower]
var can_interact = true

func _ready():

	var player_list = PlayerUnits.get_player_list()
	get_parent().get_parent().connect("finished",Callable(self,"_reactivate"))
	Globals.has_control = true
	line_2d.add_point(global_position)
	for i in player_list.size():
		if i > 0:
			var instance = player_follower.instantiate()
			instance.sprite = player_list[i].texture
			add_child(instance)
			follower_list.append(instance)
			line_2d.add_point(global_position)

func _reactivate():
	Globals.has_control = true
# Called every frame. 'delta' is the elapsed time si$Sprite2Dnce the previous frame.
func _physics_process(delta):
	line_2d.global_position = Vector2(0,0)
	line_2d.points[0] = global_position
	for i in follower_list.size():
		follower_list[i].target = line_2d.points[i+1] 
	move(delta)
	if Input.is_action_just_pressed("ui_select") and raycast.is_colliding() and Globals.has_control:
		if raycast.get_collider().get_parent() is InteractableObject:
			can_interact = false
			timer.start()
			raycast.get_collider().get_parent().interact()
	

func move(delta):
	if Globals.has_control:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		input_vector = input_vector.normalized()	
		if input_vector != Vector2.ZERO:
			raycast.target_position = input_vector * 10
			velo = velo.move_toward(input_vector*max_speed,acc*delta)
		else:
			velo = velo.move_toward(Vector2.ZERO,fric*delta)
	else:
		velo = Vector2.ZERO
	if velocity.length() > 0:
		animation_player.play("Move")
	else:
		animation_player.play("Idle")
	if velo.x > 0:
		sprite_2d.flip_h = false
	elif velo.x < 0:
		sprite_2d.flip_h = true
	set_velocity(velo)
	move_and_slide()
	velo = velo
	


func _on_timer_timeout():
	can_interact = true
