@tool
extends EditorScenePostImport


func _post_import(scene : Node) -> Object:
	scene.get_child(0).scale = 6.0 * Vector3.ONE
	var mesh : MeshInstance3D = scene.get_child(0).get_child(0)
	mesh.create_convex_collision(true, true)
	return scene
