extends MenuItem
class_name SpellLabel

@export var spell: Spell

func cursor_select():
	print(name)
	emit_signal("cursor_selected")

func _initialize(spell: Spell):
	self.spell = spell
	self.text = spell.spell_name.to_upper()
