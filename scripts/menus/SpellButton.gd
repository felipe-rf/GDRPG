extends ActionButton
class_name SpellButton

@export var spell: Spell

func cursor_select()-> void:
	print(name)
	emit_signal("cursor_selected")

func _initialize(spell: Spell)-> void:
	self.spell = spell
	self.text = spell.spell_name.to_upper()
