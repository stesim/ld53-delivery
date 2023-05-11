@tool
extends EditorScenePostImport


const SCALE := 6.0 * Vector3.ONE

const MATERIALS := {
	"asphalt": preload("material_asphalt.tres"),
	"asphaltEdge": preload("material_asphalt_edge.tres"),
	"line": preload("material_line.tres"),
	"pavement": preload("material_pavement.tres"),
}


func _post_import(scene : Node) -> Object:
	var mesh_instance : MeshInstance3D = scene.get_child(0).get_child(0).duplicate()
	var mesh : ArrayMesh = mesh_instance.mesh
	for i in mesh.get_surface_count():
		var surface_name := mesh.surface_get_name(i)
		var common_material : BaseMaterial3D = MATERIALS.get(surface_name)
		if common_material:
			mesh.surface_set_material(i, common_material)
	mesh_instance.position = Vector3.ZERO
	mesh_instance.scale = SCALE
	mesh_instance.create_trimesh_collision()
	_set_subtree_owner(mesh_instance, mesh_instance)
	var scene_copy := PackedScene.new()
	scene_copy.pack(mesh_instance)
	ResourceSaver.save(scene_copy, _get_save_path())
	return scene


func _set_subtree_owner(node : Node, owner : Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_set_subtree_owner(child, owner)


func _get_save_path() -> String:
	var script_path : String = get_script().resource_path
	var save_dir := script_path.get_base_dir()
	var source_file := get_source_file().get_file()
	var destination_file := source_file.get_basename() + ".tscn"
	return save_dir.path_join(destination_file)
