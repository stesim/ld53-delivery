class_name CurveFollow3D
extends Node3D


signal end_reached()


@export var path : Curve3D = null :
	set(value):
		path = value
		is_moving = is_moving or (auto_start and path != null)
		offset = 0.0

@export var is_moving := false :
	set(value):
		is_moving = value
		set_physics_process(is_moving and path != null)

@export var auto_start := true

@export var speed := 1.0

@export var offset := 0.0 :
	set(value):
		offset = value
		if path:
			position = path.sample_baked(offset)


func _ready() -> void:
	if auto_start:
		is_moving = true


func _physics_process(delta : float) -> void:
	var path_length := path.get_baked_length()
	offset = clampf(offset + delta * speed, 0.0, path_length)
	if is_equal_approx(offset, path_length):
		is_moving = false
		end_reached.emit()
