extends AnimationPlayer


signal attack_hit

func _ready():
	autoplay = "unit/Idle"
func _attack_hit():
	emit_signal("attack_hit")
