class_name SmoothedFollow
extends Node3D


@export var target : Node3D
@export var speed := 5.0


@export var offset := Vector3.ZERO


func _ready() -> void:
	if offset == Vector3.ZERO:
		offset = global_position - target.global_position


func _physics_process(delta : float) -> void:
	var ideal_position := target.global_position + offset.rotated(Vector3.UP, target.global_rotation.y)
	var interpolated_position := global_position.lerp(ideal_position, delta * speed)
	look_at_from_position(interpolated_position, target.global_position)
