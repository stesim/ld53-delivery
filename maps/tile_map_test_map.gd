@tool
extends Node3D


const ROAD_TERRAIN_SET_INDEX := 0
const ROAD_TERRAIN_INDEX := 0
const SCENE_LAYER_INDEX := 0
const SCENE_ROTATION_LAYER_INDEX := 1


@export var tile_size_coarse := 6.0 * Vector3.ONE
@export var tile_size_regular := 2.0 * Vector3.ONE
@export var building_ground_height := 0.12

@export var update : bool :
	get: return false
	set(_value): _update()


var _container_coarse_tiles : Node3D = null
var _container_regular_tiles : Node3D = null
var _container_building_tiles : Node3D = null


@onready var _tile_map_coarse : TileMap = $tile_map_coarse
@onready var _tile_map_regular : TileMap = $tile_map_regular


func _ready() -> void:
	if not Engine.is_editor_hint():
		_tile_map_coarse.hide()
		_tile_map_regular.hide()

	_update()


func _update() -> void:
	_container_coarse_tiles = _recreate_container(&"_generated_tiles_coarse")
	_generate_scenes_from_tiles(_tile_map_coarse, tile_size_coarse, _container_coarse_tiles, 0)

	var regular_tiles_offset := Vector3(
		-0.5 * (tile_size_coarse.x - tile_size_regular.x),
		0.0,
		-0.5 * (tile_size_coarse.y - tile_size_regular.y),
	)
	_container_regular_tiles = _recreate_container(&"_generated_tiles_regular")
	_container_regular_tiles.position = regular_tiles_offset
	_generate_scenes_from_tiles(_tile_map_regular, tile_size_regular, _container_regular_tiles, 0)

	_container_building_tiles = _recreate_container(&"_generated_tiles_buildings")
	_container_building_tiles.position = regular_tiles_offset + building_ground_height * Vector3.UP
	_generate_scenes_from_tiles(_tile_map_regular, tile_size_regular, _container_building_tiles, 1)


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


#func _get_tile_source(tile_set : TileSet, source_name : String) -> TileSetSource:
#	for i in tile_set.get_source_count():
#		var id := tile_set.get_source_id(i)
#		var source := tile_set.get_source(id)
#		if source.resource_name == source_name:
#			return source
#	return null


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
