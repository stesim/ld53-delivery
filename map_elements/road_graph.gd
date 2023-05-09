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
	var end_time := Time.get_ticks_msec()
	print("[%s] regenerated road graph in %dms" % [name, end_time - start_time])


func _generate_roads() -> void:
	for y in grid_size.y - 1:
		for x in grid_size.x - 1:
			if y == 0:
				_create_road_from_coordinates(Vector2i(x, y), Vector2i(x + 1, y))
			if x == 0:
				_create_road_from_coordinates(Vector2i(x, y), Vector2i(x, y + 1))

			_create_road_from_coordinates(Vector2i(x, y + 1), Vector2i(x + 1, y + 1))
			_create_road_from_coordinates(Vector2i(x + 1, y), Vector2i(x + 1, y + 1))


func _create_road_from_coordinates(from : Vector2i, to : Vector2i) -> void:
	var from_intersection := _get_intersection_at_coordinates(from)
	var to_intersection := _get_intersection_at_coordinates(to)

	var road := Road.new()
	road.from = from_intersection
	road.to = to_intersection
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


func _create_intersection(location : Vector3) -> void:
	var intersection := RoadIntersection.new()
	intersection.position = location
	add_child(intersection)
	intersection.owner = owner


func _compute_intersection_geometry(coordinates : Vector2i) -> PackedVector2Array:
	var points := PackedVector2Array()

	var intersection := _get_intersection_at_coordinates(coordinates)
	for road_ in intersection.roads:
		var road : Road = road_
		var is_start := intersection == road.from
		var tangent := road.get_tangent(0.0) if is_start else -road.get_tangent(1.0)
		var normal := road.get_normal(0.0) if is_start else -road.get_normal(1.0)


	return points


func _clear_children() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
