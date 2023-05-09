@tool
class_name Road
extends Path3D


var from : RoadIntersection
var from_offset := 0.0
var to : RoadIntersection
var to_offset := 0.0
var width := 0.0


func _ready() -> void:
	if not Engine.is_editor_hint():
		return

	curve = Curve3D.new()
	curve.point_count = 2
	update()


func update() -> void:
	position = 0.5 * (from.position + to.position)

	var diff := to.position - from.position
	var dir := diff.normalized()
	curve.set_point_position(0, -0.5 * diff + from_offset * dir)
	curve.set_point_position(1, 0.5 * diff - to_offset * dir)


func get_tangent(length_fraction : float) -> Vector3:
	var local_transform := curve.sample_baked_with_rotation(length_fraction * curve.get_baked_length())
	return -local_transform.basis.z


func get_normal(length_fraction : float) -> Vector3:
	var local_transform := curve.sample_baked_with_rotation(length_fraction * curve.get_baked_length())
	return local_transform.basis.x


func get_position_at_intersection(intersection : RoadIntersection) -> Vector3:
	var point_index := 0
	match intersection:
		from: point_index = 0
		to: point_index = curve.point_count - 1
		_: return Vector3.ZERO
	return position + curve.get_point_position(point_index)


func get_tangent_at_intersection(intersection : RoadIntersection) -> Vector3:
	match intersection:
		from: return get_tangent(0.0)
		to: return -get_tangent(1.0)
	return Vector3.ZERO


func get_normal_at_intersection(intersection : RoadIntersection) -> Vector3:
	match intersection:
		from: return get_normal(0.0)
		to: return -get_normal(1.0)
	return Vector3.ZERO
