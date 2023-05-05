extends Camera3D


const MAX_PITCH := 0.5 * PI - 0.1


@export var target : Node3D
@export_range(0.0, 1.0) var smoothing := 0.9

@export var adjustment_rotation_speed := 0.0025
@export var adjustment_zoom_speed := 1.0
@export var adjustment_translation_speed := 2.0

@export var configs : Array[TrackingCameraConfig] = []

var _current_config : TrackingCameraConfig = null

var _adjusted_config := TrackingCameraConfig.new()

var _is_adjusting := false


func _ready() -> void:
	_cycle_configs()


func _physics_process(_delta : float) -> void:
	if target:
		var offset := _current_config.distance * (
			Vector3.FORWARD
			.rotated(Vector3.RIGHT, _current_config.pitch)
			.rotated(Vector3.UP, _current_config.yaw)
		)

		var ideal_position := target.global_position + offset.rotated(Vector3.UP, target.global_rotation.y)
		var interpolated_position := ideal_position.slerp(global_position, smoothing)
		look_at_from_position(interpolated_position, target.global_position)


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"change_camera"):
		_cycle_configs()
	if event.is_action(&"adjust_camera"):
		_toggle_adjustment(event.is_pressed())
	if event.is_action(&"zoom_in"):
		_change_zoom(+1)
	if event.is_action(&"zoom_out"):
		_change_zoom(-1)

	if _is_adjusting and event is InputEventMouseMotion:
		_copy_current_to_adjusted_config()
		var motion : Vector2 = event.relative
		_adjusted_config.yaw -= adjustment_rotation_speed * motion.x
		_adjusted_config.pitch = clampf(_adjusted_config.pitch + adjustment_rotation_speed * motion.y, 0.0, MAX_PITCH)
		_current_config = _adjusted_config


func _cycle_configs() -> void:
	if not configs.is_empty():
		var next_config_index := (configs.find(_current_config) + 1) % configs.size()
		_current_config = configs[next_config_index]
	elif _current_config != _adjusted_config:
		_current_config = _adjusted_config


func _copy_current_to_adjusted_config() -> void:
	if _current_config == _adjusted_config:
		return
	_adjusted_config.yaw = _current_config.yaw
	_adjusted_config.pitch = _current_config.pitch
	_adjusted_config.distance = _current_config.distance


func _change_zoom(step_sign : float) -> void:
	_copy_current_to_adjusted_config()
	_adjusted_config.distance = maxf(1.0, _adjusted_config.distance - step_sign * adjustment_zoom_speed)
	_current_config = _adjusted_config


func _toggle_adjustment(enabled : bool) -> void:
	_is_adjusting = enabled
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if _is_adjusting else Input.MOUSE_MODE_VISIBLE
