extends AnimationPlayer


func _on_animation_finished(anim_name):
	self.queue_free()
