extends Marker2D
 
@export var damage_node : PackedScene
var i = 0 
func _ready():
	randomize()
 
func popup(dmg: String,type: int,damage_type:int=0):
	
	var damage = damage_node.instantiate()
	damage.get_node("Label").label_settings = LabelSettings.new()
	if(i == 1):
		damage.position = global_position - Vector2(0,30)
		i = -1
	else: damage.position = global_position
	match type:
		0:
			damage.get_node("Label").text = "+" + dmg
			damage.get_node("Label").label_settings.font_color = Color.LIGHT_SEA_GREEN
		1:
			damage.get_node("Label").text = "-" + dmg
			damage.get_node("Label").label_settings.font_color = _get_color(damage_type)
		2:
			damage.get_node("Label").label_settings.font_color = Color.WHITE
			damage.get_node("Label").text = dmg
	var tween = get_tree().create_tween()
	tween.tween_property(damage,
						 "position",
						 global_position + _get_direction(),
						 0.75)


	get_tree().current_scene.add_child(damage)
	i += 1
 
func _get_color(damage_type:int) -> Color:
	match damage_type:
		DamageTypes.Fire:
			return Color.ORANGE
		DamageTypes.Ice:
			return Color.SKY_BLUE
		DamageTypes.Shock:
			return Color.GREEN_YELLOW
	return Color.WHITE
func _get_direction():
	randomize()
	return Vector2(randf_range(-1,1), -randf()) * 16
 
 
