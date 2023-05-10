@tool
class_name Block
extends Node3D


@export var buildings : Array[Mesh] = []

@export var mesh_scale := Vector3.ONE

@export var polygon : PackedVector2Array

@export var regenerate : bool :
	get: return false
	set(_value): _regenerate()


func _regenerate() -> void:
	_clear_children()

	if buildings.is_empty() or polygon.size() < 2:
		return

	var min_width := _get_building_width(buildings[0])
	var max_width := min_width
	var max_depth := _get_building_depth(buildings[0])
	for building in buildings:
		var footprint := _get_building_footprint(building)
		var width := footprint.size.x
		min_width = minf(width, min_width)
		max_width = maxf(width, max_width)
		var depth := footprint.size.y
		max_depth = maxf(depth, max_depth)

	var deflated_polygon = Geometry2D.offset_polygon(polygon, -max_depth, Geometry2D.JOIN_MITER)[0]
	for i in deflated_polygon.size():
		_distribute_along_segment(
			deflated_polygon[i],
			deflated_polygon[(i + 1) % deflated_polygon.size()],
			min_width,
			max_width,
		)


func _distribute_along_segment(from : Vector2, to : Vector2, min_width : float, max_width : float) -> void:
	var segment_length := from.distance_to(to)
	var container := Node3D.new()
	container.position = _vector2_to_3(from)
	container.rotation.y = -(to - from).angle()
	add_child(container)

	var selected_buildings : Array[Mesh] = []

	var remaining_length := segment_length
	while remaining_length >= min_width:
		var suitable_buildings := buildings
		if remaining_length < max_width:
			suitable_buildings = suitable_buildings.duplicate().filter(
				func(building): return _get_building_width(building) <= remaining_length
			)
		var building : Mesh = suitable_buildings.pick_random()
		selected_buildings.push_back(building)
		remaining_length -= _get_building_width(building)

	var current_offset := 0.5 * remaining_length
	for building in selected_buildings:
		var footprint := _get_building_footprint(building)
		var footprint_offset := -footprint.position
		var instance := MeshInstance3D.new()
		instance.mesh = building
		instance.position.x = current_offset + footprint_offset.x
		instance.position.z = -footprint.position.y
		instance.scale = mesh_scale
		container.add_child(instance)
		var collision := _create_collision_shape(instance)
		collision.position.x = current_offset
		current_offset += footprint.size.x


func _create_collision_shape(building_instance : MeshInstance3D) -> StaticBody3D:
	var container := building_instance.get_parent()
	var body := StaticBody3D.new()
	container.add_child(body)

	var building := building_instance.mesh
	var footprint := _get_building_footprint(building)
	var height := mesh_scale.y * building.get_aabb().size.y

	var collision_shape := CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.size = Vector3(footprint.size.x, height, footprint.size.y)
	collision_shape.position = 0.5 * collision_shape.shape.size
	collision_shape.position.z = -collision_shape.position.z
	body.add_child(collision_shape)
	return body


func _get_building_width(building) -> float:
	return _get_building_footprint(building).size.x


func _get_building_depth(building) -> float:
	return _get_building_footprint(building).size.y


func _get_building_footprint(building) -> Rect2:
	var footprint_scale := _vector3_to_2(mesh_scale)
	var footprint : Rect2 = building.get_meta(&"footprint")
	footprint.size = (footprint.size * footprint_scale).abs()
	footprint.position *= footprint_scale
	return footprint


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _vector3_to_2(v : Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func _vector2_to_3(v : Vector2) -> Vector3:
	return Vector3(v.x, 0.0, v.y)
