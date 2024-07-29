extends Node
class_name PlayerInventory

@export var inventory: Array[Item]

func _use_item(item: Item):
	item.quantity -= 1
	if(item.quantity == 0):
		inventory.erase(item)
