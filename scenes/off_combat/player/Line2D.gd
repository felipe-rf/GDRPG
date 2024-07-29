@tool
extends Line2D

@export var max_distance: int = 10
@export var max_angle: float = 10
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_restrain_point(0,0)


func _restrain_point(parent_point,point):
	points[point] = constrain_angle(points[parent_point],points[point],max_angle)
	points[point] = constrain_distance(points[parent_point],points[point],max_distance)


	if point+1 < points.size():
		_restrain_point(point,point+1)
	else: return

func constrain_distance(parent_point,point,_max_distance)-> Vector2:
	return parent_point + (point - parent_point).limit_length(_max_distance)

func constrain_angle(parent_point,point,_max_angle)-> Vector2:
	return point.clamp(parent_point.from_angle(_max_angle),point)
