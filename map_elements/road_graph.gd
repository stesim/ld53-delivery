@tool
class_name RoadGraph
extends Node3D


@export var cross_section_path : NodePath :
	set(value):
		cross_section_path = value
		_cross_section = get_node_or_null(cross_section_path)

@export var block_size := Vector2(32.0, 32.0)

@export var grid_size := Vector2i(8, 8)

@export_range(0.0, 1.0) var uniformity := 0.5

@export var road_width := 6.5

@export var road_height := 0.1

@export var regenerate : bool :
	get: return false
	set(_value): _regenerate()


var _cross_section : CSGPolygon3D = null


func _ready() -> void:
	if not Engine.is_editor_hint():
		return

	cross_section_path = cross_section_path


func _regenerate() -> void:
	var start_time := Time.get_ticks_msec()
	_clear_children()
	_generate_intersections()
	_generate_roads()
	_offset_roads_from_intersections()
	_create_intersection_meshes()
	var end_time := Time.get_ticks_msec()
	print("[%s] regenerated road graph in %dms" % [name, end_time - start_time])


func _generate_roads() -> void:
	for y in grid_size.y - 1:
		for x in grid_size.x - 1:
			if x == 0:
				_create_road_from_coordinates(Vector2i(x, y), Vector2i(x, y + 1))

			_create_road_from_coordinates(Vector2i(x, y + 1), Vector2i(x + 1, y + 1))
			_create_road_from_coordinates(Vector2i(x + 1, y), Vector2i(x + 1, y + 1))

			if y == 0:
				_create_road_from_coordinates(Vector2i(x, y), Vector2i(x + 1, y))


func _create_road_from_coordinates(from : Vector2i, to : Vector2i) -> void:
	var from_intersection := _get_intersection_at_coordinates(from)
	var to_intersection := _get_intersection_at_coordinates(to)

	var road := Road.new()
	road.from = from_intersection
	road.to = to_intersection
	road.width = road_width
	add_child(road)
	road.owner = owner

	from_intersection.roads.push_back(road)
	to_intersection.roads.push_back(road)

	if _cross_section:
		var mesh : CSGPolygon3D = _cross_section.duplicate()
		if mesh.mode != CSGPolygon3D.MODE_PATH:
			mesh.mode = CSGPolygon3D.MODE_PATH
			mesh.path_simplify_angle = deg_to_rad(1.0)
		mesh.path_local = true
		mesh.path_node = ^".."
		road.add_child(mesh)
		mesh.owner = owner


func _get_intersection_at_coordinates(coordinates : Vector2i) -> RoadIntersection:
	return get_child(coordinates.y * grid_size.x + coordinates.x)


func _generate_intersections() -> void:
	var randomness := 1.0 - uniformity
	for y in grid_size.y:
		for x in grid_size.x:
			var point := Vector3(
				(x + randf() * randomness) * block_size.x,
				0.0,
				(y + randf() * randomness) * block_size.y,
			)
			_create_intersection(point)

	if get_child_count() > 0:
		get_child(0).position = Vector3(0.5 * block_size.x, 0.0, 0.5 * block_size.y)


func _create_intersection(location : Vector3) -> void:
	var intersection := RoadIntersection.new()
	intersection.position = location
	add_child(intersection)
	intersection.owner = owner


func _offset_roads_from_intersections() -> void:
	var num_intersections := grid_size.y * grid_size.x
	for i in num_intersections:
		var intersection := get_child(i)
		_offset_roads_from_intersection(intersection)

	for i in range(num_intersections, get_child_count()):
		var road : Road = get_child(i)
		road.update()


func _offset_roads_from_intersection(intersection : RoadIntersection) -> void:
	for i in intersection.roads.size():
		var road : Road = intersection.roads[i]
		var offset := _compute_road_offset_from_intersection(intersection, i)
		if intersection == road.from:
			road.from_offset = offset
		else:
			road.to_offset = offset


func _compute_road_offset_from_intersection(intersection : RoadIntersection, road_index : int) -> float:
	var roads := intersection.roads
	var center_road := roads[road_index]
	var left_road := roads[(road_index - 1) % roads.size()]
	var right_road := roads[(road_index + 1) % roads.size()]

	var center_tangent := _vector3_to_2(center_road.get_tangent_at_intersection(intersection)).normalized()
	var left_tangent := _vector3_to_2(left_road.get_tangent_at_intersection(intersection)).normalized()
	var right_tangent := _vector3_to_2(right_road.get_tangent_at_intersection(intersection)).normalized()

	var angle_left := absf(center_tangent.angle_to(left_tangent))
	var angle_right := absf(center_tangent.angle_to(right_tangent))

	var offset_left := 0.5 * road_width / tan(0.5 * angle_left)
	var offset_right := 0.5 * road_width / tan(0.5 * angle_right)
	return maxf(offset_left, offset_right)


func _create_intersection_meshes() -> void:
	for i in grid_size.y * grid_size.x:
		var intersection := get_child(i)
		_create_intersection_mesh(intersection)


func _create_intersection_mesh(intersection : RoadIntersection) -> void:
	var polygon := CSGPolygon3D.new()
	polygon.polygon = _compute_intersection_geometry(intersection)
	polygon.use_collision = true
	polygon.depth = road_height
	polygon.rotation.x = 0.5 * PI
	intersection.add_child(polygon)
	polygon.owner = owner


func _compute_intersection_geometry(intersection : RoadIntersection) -> PackedVector2Array:
	var points := PackedVector2Array()

	var intersection_position := _vector3_to_2(intersection.position)
	var roads := intersection.roads
	for i in roads.size():
		var road := roads[i]
		var center := _vector3_to_2(road.get_position_at_intersection(intersection))
		var normal := _vector3_to_2(road.get_normal_at_intersection(intersection)).normalized()
		var offset := 0.5 * road_width * normal
		var left := center + offset - intersection_position
		var right := center - offset - intersection_position

		if i == 0 or not _vec_is_equal_approx(left, points[points.size() - 1]):
			points.push_back(left)
		if i < roads.size() - 1 or not _vec_is_equal_approx(right, points[0]):
			points.push_back(right)

	return points


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _vector3_to_2(v : Vector3) -> Vector2:
	return Vector2(v.x, v.z)


const EPSILON_COARSE := 0.001

func _vec_is_equal_approx(v : Vector2, w : Vector2) -> bool:
	return absf(v.x - w.x) < EPSILON_COARSE and absf(v.y - w.y) < EPSILON_COARSE
