@tool
extends Node3D


const GROUND_LAYER := 0
const BUILDING_LAYER := 1
const POI_LAYER := 2

const ROAD_TERRAIN_SET_INDEX := 0
const ROAD_TERRAIN_INDEX := 0

const SCENE_LAYER_INDEX := 0
const SCENE_ROTATION_LAYER_INDEX := 1
const WALKABLE_LAYER_INDEX := 2


@export var tile_size_coarse := 6.0 * Vector3.ONE
@export var tile_size_regular := 2.0 * Vector3.ONE
@export var building_ground_height := 0.12

@export var num_characters := 16
@export var character_speed_min := 0.5
@export var character_speed_max := 2.5

@export var update : bool :
	get: return false
	set(_value): _update()


var _container_coarse_tiles : Node3D = null
var _container_regular_tiles : Node3D = null
var _container_building_tiles : Node3D = null

var _container_characters : Node3D = null

var _astar := AStarGrid2D.new()
var _astar_region := Rect2i()

var _poi_paths : Array[PoiPath] = []


@onready var _tile_map_coarse : TileMap = $tile_map_coarse
@onready var _tile_map_regular : TileMap = $tile_map_regular


func _ready() -> void:
	if not Engine.is_editor_hint():
		_tile_map_coarse.hide()
		_tile_map_regular.hide()

	_astar.jumping_enabled = true
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES

	_update()


func _update() -> void:
	var coarse_tiles_offset := Vector3(0.5 * tile_size_coarse.x, 0.0, 0.5 * tile_size_coarse.y)
	_container_coarse_tiles = _recreate_container(&"_generated_tiles_coarse")
	_container_coarse_tiles.position = coarse_tiles_offset
	_generate_scenes_from_tiles(_tile_map_coarse, tile_size_coarse, _container_coarse_tiles, GROUND_LAYER)

	var regular_tiles_offset := Vector3(0.5 * tile_size_regular.x, 0.0, 0.5 * tile_size_regular.y)
	_container_regular_tiles = _recreate_container(&"_generated_tiles_regular")
	_container_regular_tiles.position = regular_tiles_offset
	_generate_scenes_from_tiles(_tile_map_regular, tile_size_regular, _container_regular_tiles, GROUND_LAYER)

	_container_building_tiles = _recreate_container(&"_generated_tiles_buildings")
	_container_building_tiles.position = regular_tiles_offset + building_ground_height * Vector3.UP
	_generate_scenes_from_tiles(_tile_map_regular, tile_size_regular, _container_building_tiles, BUILDING_LAYER)

	if not Engine.is_editor_hint():
		_setup_navigation()
		_precompute_poi_paths()
		_create_characters()


func _generate_scenes_from_tiles(tile_map : TileMap, tile_size : Vector3, container : Node, layer : int) -> void:
	var tile_set := tile_map.tile_set
	assert(tile_set.get_custom_data_layer_name(SCENE_LAYER_INDEX) == "Scene")
	assert(tile_set.get_custom_data_layer_name(SCENE_ROTATION_LAYER_INDEX) == "Scene Rotation")

	var indices := tile_map.get_used_cells(layer)
	for index in indices:
		var tile_data := tile_map.get_cell_tile_data(layer, index)
		var tile_scene : PackedScene = tile_data.get_custom_data_by_layer_id(SCENE_LAYER_INDEX)
		if tile_scene:
			var tile_instance : Node3D = tile_scene.instantiate()
			tile_instance.position = Vector3(index.x, 0.0, index.y) * tile_size
			tile_instance.rotation.y = PI * tile_data.get_custom_data_by_layer_id(SCENE_ROTATION_LAYER_INDEX)
			container.add_child(tile_instance)


func _setup_navigation() -> void:
	_astar_region = _tile_map_regular.get_used_rect()

	_astar.clear()
	_astar.size = _astar_region.size
	_astar.update()

	for y in _astar_region.size.y:
		for x in _astar_region.size.x:
			var id := Vector2i(x, y)
			var tile_map_coords := _astar_region.position + id
			var ground_data := _tile_map_regular.get_cell_tile_data(GROUND_LAYER, tile_map_coords)
			var is_walkable : bool = ground_data != null and ground_data.get_custom_data_by_layer_id(WALKABLE_LAYER_INDEX)
			if is_walkable:
				var is_building := _tile_map_regular.get_cell_tile_data(BUILDING_LAYER, tile_map_coords) != null
				is_walkable = is_walkable and not is_building

			if not is_walkable:
				_astar.set_point_solid(id)


func _precompute_poi_paths() -> void:
	var poi_ids = _get_poi_astar_ids()
	for from in poi_ids:
		for to in poi_ids:
			if from == to:
				continue
			var id_path := _astar.get_id_path(from, to)
			if id_path.is_empty():
				continue

			var curve := Curve3D.new()
			curve.bake_interval = tile_size_regular.x
			curve.point_count = id_path.size()
			for i in curve.point_count:
				var id_position := _astar_cell_id_to_world_position(id_path[i])
				curve.set_point_position(i, id_position)
			_poi_paths.push_back(PoiPath.create(from, to, curve))


func _create_characters() -> void:
	_container_characters = _recreate_container(&"_characters")
	_container_characters.position.y = 1.0

	var character_mesh : Node3D = $character_mesh
	for _i in num_characters:
		var character := CurveFollow3D.new()
		_pick_random_path_for_character(character)
		character.offset = randf() * character.path.get_baked_length()
		character.speed = randf_range(character_speed_min, character_speed_max)
		character.end_reached.connect(_pick_random_path_for_character.bind(character))

		var mesh := character_mesh.duplicate()
		mesh.visible = true
		character.add_child(mesh)

		_container_characters.add_child(character)


func _pick_random_path_for_character(character : CurveFollow3D) -> void:
	character.path = _poi_paths.pick_random().path


func _get_poi_astar_ids() -> Array[Vector2i]:
	var tile_map_cells := _tile_map_regular.get_used_cells(POI_LAYER)
	var ids : Array[Vector2i] = []
	ids.resize(tile_map_cells.size())
	for i in tile_map_cells.size():
		var astar_cell_id := _tile_map_index_to_astar_cell_id(tile_map_cells[i])
		ids[i] = astar_cell_id
	return ids


func _world_position_to_astar_cell_id(world_position : Vector3) -> Vector2i:
	var tiles_local_position := _container_regular_tiles.to_local(world_position)
	var fractional_grid_position := tiles_local_position / tile_size_regular
	var tile_map_index := Vector2i(
		floori(fractional_grid_position.x),
		floori(fractional_grid_position.z),
	)
	var astar_cell_id := _tile_map_index_to_astar_cell_id(tile_map_index)
	return astar_cell_id


func _astar_cell_id_to_world_position(id : Vector2i) -> Vector3:
	var tile_map_index := _astar_region.position + id
	var tile_map_position := Vector3(tile_map_index.x, 0.0, tile_map_index.y) * tile_size_regular
	return _container_regular_tiles.to_global(tile_map_position)


func _tile_map_index_to_astar_cell_id(index : Vector2i) -> Vector2i:
	return index - _astar_region.position


func _recreate_container(node_name : String) -> Node3D:
	var container : Node3D = get_node_or_null(node_name)
	if container:
		_remove(container)
	return _create_container(node_name)


func _create_container(node_name : StringName) -> Node3D:
	var container := Node3D.new()
	container.name = node_name
	add_child(container)
	return container


func _remove(child : Node) -> void:
	if child:
		remove_child(child)
		child.queue_free()


class PoiPath extends RefCounted:
	var from : Vector2i
	var to : Vector2i
	var path : Curve3D

	static func create(from_ : Vector2i, to_ : Vector2i, path_ : Curve3D) -> PoiPath:
		var instance := PoiPath.new()
		instance.from = from_
		instance.to = to_
		instance.path = path_
		return instance
