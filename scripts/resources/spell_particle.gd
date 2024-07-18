extends GPUParticles2D

func _ready() -> void:
	one_shot = true
	emitting = true
	
func _on_finished() -> void:
	self.queue_free()
