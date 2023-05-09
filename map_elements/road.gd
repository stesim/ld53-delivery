@tool
class_name Road
extends Path3D


var from : RoadIntersection
var to : RoadIntersection


func _ready() -> void:
	if not Engine.is_editor_hint():
		return

	position = 0.5 * (from.position + to.position)

	curve = Curve3D.new()
	curve.point_count = 2
	var diff := to.position - from.position
	curve.set_point_position(0, -0.5 * diff)
	curve.set_point_position(1, 0.5 * diff)


func get_tangent(length_fraction : float) -> Vector3:
	var local_transform := curve.sample_baked_with_rotation(length_fraction * curve.get_baked_length())
	return -local_transform.basis.z


func get_normal(length_fraction : float) -> Vector3:
	var local_transform := curve.sample_baked_with_rotation(length_fraction * curve.get_baked_length())
	return local_transform.basis.x
