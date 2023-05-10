@tool
class_name RoadGraph
extends Node3D


@export var block_size := Vector2(32.0, 32.0)

@export var grid_size := Vector2i(8, 8)

@export_range(0.0, 1.0) var uniformity := 0.5

@export var road_width := 6.5

@export var road_height := 0.1

@export var road_material : Material

@export var pavement_width := 2.0

@export var pavement_height := 0.2

@export var building_height_min := 5.0

@export var building_height_max := 20.0

@export var regenerate : bool :
	get: return false
	set(_value): _regenerate()

@export var reconstruct : bool :
	get: return false
	set(_value): _reconstruct()


var _intersections : Node3D = null
var _roads : Node3D = null
var _blocks : Node3D = null
var _buildings : Node3D = null


func _ready() -> void:
	_intersections = get_node_or_null(^"intersections")
	if _intersections:
		_reconstruct()
	else:
		_regenerate()


func _regenerate() -> void:
	var start_time := Time.get_ticks_msec()
	_generate_intersections()
	_reconstruct()
	var end_time := Time.get_ticks_msec()
	print("[%s] regenerated road graph in %dms" % [name, end_time - start_time])


func _reconstruct() -> void:
	_generate_blocks()
	_generate_roads()
	_create_intersection_meshes()
	_generate_buildings()


func _generate_intersections() -> void:
	_remove(_intersections)
	_intersections = Node3D.new()
	_intersections.name = &"intersections"
	add_child(_intersections)
	_intersections.owner = owner

	var randomness := 1.0 - uniformity
	for y in grid_size.y:
		for x in grid_size.x:
			var point := Vector3(
				(x + randf() * randomness) * block_size.x,
				0.0,
				(y + randf() * randomness) * block_size.y,
			)
			_create_intersection(point)

	if _intersections.get_child_count() > 0:
		_intersections.get_child(0).position = Vector3(0.5 * block_size.x, 0.0, 0.5 * block_size.y)


func _generate_blocks() -> void:
	_remove(_blocks)
	_blocks = Node3D.new()
	_blocks.name = &"blocks"
	add_child(_blocks)

	for y in grid_size.y - 1:
		for x in grid_size.x - 1:
			var polygon := PackedVector2Array()
			polygon.resize(4)
			polygon[0] = _vector3_to_2(_get_intersection_at_coordinates(Vector2i(x, y)).position)
			polygon[1] = _vector3_to_2(_get_intersection_at_coordinates(Vector2i(x + 1, y)).position)
			polygon[2] = _vector3_to_2(_get_intersection_at_coordinates(Vector2i(x + 1, y + 1)).position)
			polygon[3] = _vector3_to_2(_get_intersection_at_coordinates(Vector2i(x, y + 1)).position)

			var deflated_polygon := _deflate_polygon_stable(polygon, 0.5 * road_width)
			var block := _create_mesh_from_polygon(deflated_polygon, pavement_height)
			_blocks.add_child(block)


func _generate_roads() -> void:
	_remove(_roads)
	_roads = Node3D.new()
	_roads.name = &"roads"
	add_child(_roads)

	for y in grid_size.y - 1:
		for x in grid_size.x - 2:
			var left_block := _get_block_at_coordinates(Vector2i(x, y))
			var right_block := _get_block_at_coordinates(Vector2i(x + 1, y))

			var points := PackedVector2Array()
			points.resize(4)
			points[0] = right_block.polygon[0]
			points[1] = right_block.polygon[3]
			points[2] = left_block.polygon[2]
			points[3] = left_block.polygon[1]

			var road := _create_mesh_from_polygon(points, road_height)
			road.material = road_material
			_roads.add_child(road)

	for y in grid_size.y - 2:
		for x in grid_size.x - 1:
			var top_block := _get_block_at_coordinates(Vector2i(x, y))
			var bottom_block := _get_block_at_coordinates(Vector2i(x, y + 1))

			var points := PackedVector2Array()
			points.resize(4)
			points[0] = top_block.polygon[3]
			points[1] = top_block.polygon[2]
			points[2] = bottom_block.polygon[1]
			points[3] = bottom_block.polygon[0]

			var road := _create_mesh_from_polygon(points, road_height)
			road.material = road_material
			_roads.add_child(road)


func _get_block_at_coordinates(coordinates : Vector2i) -> CSGPolygon3D:
	return _blocks.get_child(coordinates.y * (grid_size.x - 1) + coordinates.x)


func _get_intersection_at_coordinates(coordinates : Vector2i) -> RoadIntersection:
	return _intersections.get_child(coordinates.y * grid_size.x + coordinates.x)


func _create_intersection_meshes() -> void:
	for y in grid_size.y - 2:
		for x in grid_size.x - 2:
			var top_left_block := _get_block_at_coordinates(Vector2i(x, y))
			var top_right_block := _get_block_at_coordinates(Vector2i(x + 1, y))
			var bottom_right_block := _get_block_at_coordinates(Vector2i(x + 1, y + 1))
			var bottom_left_block := _get_block_at_coordinates(Vector2i(x, y + 1))

			var points := PackedVector2Array()
			points.resize(4)
			points[0] = top_left_block.polygon[2]
			points[1] = top_right_block.polygon[3]
			points[2] = bottom_right_block.polygon[0]
			points[3] = bottom_left_block.polygon[1]

			var mesh := _create_mesh_from_polygon(points, road_height)
			mesh.material = road_material
			_intersections.add_child(mesh)


func _generate_buildings() -> void:
	_remove(_buildings)
	_buildings = Node3D.new()
	_buildings.name = &"buildings"
	add_child(_buildings)

	for y in grid_size.y - 1:
		for x in grid_size.x - 1:
			var polygon := _get_block_at_coordinates(Vector2i(x, y)).polygon

			var deflated_polygon := _deflate_polygon_stable(polygon, pavement_width)
			var height := randf_range(building_height_min, building_height_max)
			var building := _create_mesh_from_polygon(deflated_polygon, height)
			_buildings.add_child(building)


func _create_intersection(location : Vector3) -> void:
	var intersection := RoadIntersection.new()
	intersection.position = location
	_intersections.add_child(intersection)
	intersection.owner = owner


func _deflate_polygon_stable(polygon : PackedVector2Array, radius : float) -> PackedVector2Array:
	var deflated := Geometry2D.offset_polygon(polygon, -radius, Geometry2D.JOIN_MITER)[0]

	# assert(deflated.size() == polygon.size())
	if deflated.size() != polygon.size():
		push_error("deflation resulted in %d vertices (originally %d)" % [deflated.size(), polygon.size()])

	var original_topmost_point := 0 if polygon[0].y < polygon[1].y else 1
	var deflated_topmost_point := 0
	for i in range(1, deflated.size()):
		if deflated[i].y < deflated[deflated_topmost_point].y:
			deflated_topmost_point = i

	if deflated_topmost_point == original_topmost_point:
		return deflated

	var shift := deflated_topmost_point - original_topmost_point
	var reordered := PackedVector2Array()
	reordered.resize(deflated.size())
	for i in reordered.size():
		reordered[i] = deflated[(i + shift) % deflated.size()]
	return reordered


func _create_mesh_from_polygon(points : PackedVector2Array, height : float) -> CSGPolygon3D:
	var polygon := CSGPolygon3D.new()
	polygon.polygon = points
	polygon.use_collision = true
	polygon.depth = height
	polygon.rotation.x = 0.5 * PI
	return polygon


func _clear_constructed_children() -> void:
	for child in get_children():
		if child != _intersections:
			remove_child(child)
			child.queue_free()


func _remove(child : Node) -> void:
	if child:
		remove_child(child)
		child.queue_free()


func _vector3_to_2(v : Vector3) -> Vector2:
	return Vector2(v.x, v.z)


const EPSILON_COARSE := 0.001

func _vec_is_equal_approx(v : Vector2, w : Vector2) -> bool:
	return absf(v.x - w.x) < EPSILON_COARSE and absf(v.y - w.y) < EPSILON_COARSE
