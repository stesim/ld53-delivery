extends VehicleBody3D


@export var active := false :
	set(value):
		active = value
		set_physics_process(active)
		set_process_unhandled_input(active)
		if not active:
			if _sound_engine:
				_sound_engine.stop()
			if _skid_sound:
				_skid_sound.stop()
			engine_force = 0.0
			steering = 0.0
			brake = max_brake_force
		else:
			if _sound_engine:
				_sound_engine.play()
			if _skid_sound:
				_skid_sound.play()

@export_range(0.0, 10000.0, 0.01, "or_greater") var max_engine_force := 6000.0
@export var power_curve : Curve
@export_range(0.0, 20.0, 0.01, "or_greater") var max_speed := 16.0
@export_range(0.0, 100.0) var max_brake_force := 1.0
@export_range(0.0, 90.0, 0.01, "radians") var max_steering_angle := 0.25 * PI
@export_range(0.0, 20.0, 0.01, "or_greater") var crash_sound_speed_threshold := 5.0
@export_range(0.0, 20.0, 0.01, "or_greater") var brake_sound_speed_threshold := 4.0
@export_range(0.0, 20.0, 0.01, "or_greater") var skid_sound_speed_threshold := 1.5


var move_forward := false

var _speed := 0.0
var _slip_speed := 0.0


@onready var _crash_sound := %crash_sound
@onready var _sound_engine : AudioStreamPlayer = %sound_engine
@onready var _initial_engine_sound_pitch := _sound_engine.pitch_scale
@onready var _initial_engine_sound_volume := _sound_engine.volume_db
@onready var _skid_sound : AudioStreamPlayer = %skid_sound


func _ready() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	if not active:
		brake = max_brake_force


func _physics_process(_delta : float) -> void:
	var velocity := linear_velocity
	var global_basis := global_transform.basis
	var forward_velocity := velocity.dot(global_basis.z)
	_speed = absf(forward_velocity)
	_slip_speed = absf(velocity.dot(global_basis.x))

	var was_braking := brake > 0.0

	engine_force = power_curve.sample_baked(_speed / max_speed) * max_engine_force * Input.get_axis("reverse", "accelerate")
	brake = max_brake_force * Input.get_action_strength("brake")
	steering = max_steering_angle * Input.get_axis("steer_right", "steer_left")

	var velocity_opposes_input := signf(forward_velocity) != signf(engine_force)
	if not is_zero_approx(engine_force) and not is_zero_approx(forward_velocity) and velocity_opposes_input:
		brake = max_brake_force

	var is_braking := brake > 0.0
	if not was_braking and is_braking and _speed >= brake_sound_speed_threshold:
		_crash_sound.play()

	if _speed < 0.5:
		move_forward = false

	var skid_strength := _slip_speed - skid_sound_speed_threshold
	if skid_strength > 0.0:
		_skid_sound.stream_paused = false
		_skid_sound.volume_db = (skid_strength - 1.0) * 6.0
	else:
		_skid_sound.stream_paused = true

	_sound_engine.pitch_scale = (0.5 + _speed / 10.0) * _initial_engine_sound_pitch
	_sound_engine.volume_db = _initial_engine_sound_volume + _speed


func get_speed() -> float:
	return absf(linear_velocity.dot(global_transform.basis.z))


func get_slip_speed() -> float:
	return absf(linear_velocity.dot(global_transform.basis.x))


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"reset_vehicle"):
		_reset.call_deferred()


func _reset() -> void:
	global_rotation.z = 0.0
	global_position.y = 2.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func _on_body_entered(body : Node) -> void:
	if not active or body is RigidBody3D:
		return
	if _speed >= crash_sound_speed_threshold:
		_crash_sound.play()
