extends ColorRect

@export var id: int
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(id == 1):
		material.set("shader_parameter/resolution",get_viewport().size/2) 
		
