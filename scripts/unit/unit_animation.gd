extends AnimationPlayer


signal attack_hit

func _attack_hit():
	emit_signal("attack_hit")
