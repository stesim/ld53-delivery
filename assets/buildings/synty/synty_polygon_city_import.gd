@tool
extends EditorScenePostImport


const MATERIAL := preload("synty_polygon_city_material.tres")


func _post_import(scene : Node) -> Object:
	var mesh : Mesh = scene.get_child(0).get_child(0).mesh
	mesh.surface_set_material(0, MATERIAL)
	mesh.set_meta(&"footprint", _compute_footprint(mesh))
	var mesh_path := _get_mesh_save_path()
	ResourceSaver.save(mesh, mesh_path)
	return scene


func _get_mesh_save_path() -> String:
	var script_path : String = get_script().resource_path
	var save_dir := script_path.get_base_dir()
	var source_file := get_source_file().get_file()
	var mesh_file := source_file.get_basename() + ".res"
	return save_dir.path_join(mesh_file)


func _compute_footprint(mesh : Mesh) -> Rect2:
	var vertices : PackedVector3Array = mesh.surface_get_arrays(0)[ArrayMesh.ARRAY_VERTEX]

	var min_corner := Vector2(vertices[0].x, vertices[0].z)
	var max_corner := min_corner

	for vertex in vertices:
		if not is_zero_approx(vertex.y):
			continue
		if vertex.x < min_corner.x:
			min_corner.x = vertex.x
		elif vertex.x > max_corner.x:
			max_corner.x = vertex.x
		if vertex.z < min_corner.y:
			min_corner.y = vertex.z
		elif vertex.z > max_corner.y:
			max_corner.y = vertex.z

	return Rect2(min_corner, max_corner - min_corner)
