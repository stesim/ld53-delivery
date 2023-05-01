extends RigidBody3D


@export var item_scene : PackedScene


func _ready() -> void:
	var item_instance := item_scene.instantiate()
	item_instance.scale = 0.5 * Vector3.ONE
	add_child(item_instance)
