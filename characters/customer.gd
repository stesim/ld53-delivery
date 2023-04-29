extends Node3D


const DEFAULT_ANIMATION_SPEED := 1.0


@export_range(0.0, 100.0) var speed := 0.5
@export var target_point := Vector3.ZERO :
	set(value):
		target_point = value
		if is_inside_tree():
			look_at(target_point)


@onready var _animation_player := %AnimationPlayer


var _is_walking := false


func _ready() -> void:
	look_at(target_point)


func _physics_process(delta : float) -> void:
	var previous_position := global_position
	global_position = global_position.move_toward(target_point, delta * speed)
	var has_moved := not global_position.is_equal_approx(previous_position)
	if _is_walking and not has_moved:
		_animation_player.play(&"Idle")
		_animation_player.speed_scale = 1.0
		_is_walking = false
		queue_free()
	elif not _is_walking and has_moved:
		_animation_player.play(&"Forward")
		_animation_player.speed_scale = speed * DEFAULT_ANIMATION_SPEED
		_is_walking = true
