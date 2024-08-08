extends CanvasLayer

@export var save_screen: PackedScene

func save_game():
	var screen = save_screen.instantiate()
	screen.connect("save_finished",save_finished)
	self.add_child(screen)

func save_finished(screen):
	screen.queue_free()
	get_parent().return_to_game()
