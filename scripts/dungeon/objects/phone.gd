extends InteractableObject

func interact():
	var layout = Dialogic.start("phone_save")
	layout.register_character(load("res://dialogic/characters/phone.dch"),$".")
