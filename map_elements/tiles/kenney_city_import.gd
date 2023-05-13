@tool
extends EditorScenePostImport


var scale = 8.0 * Vector3.ONE


func _post_import(scene : Node) -> Object:
	var mesh := _extract_mesh(scene.get_child(0).get_child(0))

	var root := Node3D.new()
	root.name = _get_source_file_name().get_basename()

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = &"mesh"
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3.ZERO
	mesh_instance.scale = scale
	mesh_instance.create_trimesh_collision()

	mesh_instance.get_child(0).name = &"collision"
	mesh_instance.get_child(0).get_child(0).name = &"shape"

	root.add_child(mesh_instance)

	_extract_mesh(mesh_instance)
	_save_as_packed_scene(root)

	return scene


func _extract_mesh(mesh_instance : MeshInstance3D) -> ArrayMesh:
	var mesh : ArrayMesh = mesh_instance.mesh
	for i in mesh.get_surface_count():
		_extract_material(mesh, i)
	var path := _to_absolute("meshes".path_join(_get_source_file_name() + ".res"))
	ResourceSaver.save(mesh, path)
	return ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REUSE)


func _extract_material(mesh : ArrayMesh, surface : int) -> void:
	var surface_name := mesh.surface_get_name(surface)
	var material_file_name := _to_absolute("materials".path_join(surface_name + ".tres"))
	var material : BaseMaterial3D
	if not ResourceLoader.exists(material_file_name):
		material = mesh.surface_get_material(surface)
		ResourceSaver.save(material, material_file_name)
	material = ResourceLoader.load(material_file_name, "", ResourceLoader.CACHE_MODE_REUSE)
	mesh.surface_set_material(surface, material)


func _save_as_packed_scene(node : Node) -> void:
	_set_subtree_owner(node, node)
	var scene := PackedScene.new()
	scene.pack(node)
	var path := _to_absolute(_get_source_file_name() + ".tscn")
	ResourceSaver.save(scene, path)


func _set_subtree_owner(node : Node, owner : Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_set_subtree_owner(child, owner)


func _get_source_file_name() -> String:
	return get_source_file().get_file().get_basename()


func _to_absolute(relative_path : String) -> String:
	var script_path : String = get_script().resource_path
	var current_dir := script_path.get_base_dir()
	return current_dir.path_join(relative_path)


func _get_save_path() -> String:
	var script_path : String = get_script().resource_path
	var save_dir := script_path.get_base_dir()
	var source_file := get_source_file().get_file()
	var destination_file := source_file.get_basename() + ".tscn"
	return save_dir.path_join(destination_file)
