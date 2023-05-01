extends VehicleBody3D


@export var active := false :
	set(value):
		active = value
		set_physics_process(active)
		set_process_unhandled_input(active)
		if not active:
			_sound_engine.stop()
			engine_force = 0.0
			steering = 0.0
			brake = max_brake_force
		else:
			if _sound_engine:
				_sound_engine.play()


@export_range(0.0, 500.0, 0.01, "or_greater") var max_engine_force := 50.0
@export_range(0.0, 100.0) var max_brake_force := 1.0
@export_range(0.0, 90.0, 0.01, "radians") var max_steering_angle := 0.25 * PI
@export_range(0.0, 200.0, 0.01, "or_greater") var inventory_loss_acceleration_threshold := 50.0
@export_range(0.0, 20.0, 0.01, "or_greater") var inventory_loss_amount := 1
@export_range(0.0, 20.0, 0.01, "or_greater") var inventory_loss_cooldown := 1.0
@export_range(0.0, 20.0, 0.01, "or_greater") var crash_sound_speed_threshold := 5.0
@export_range(0.0, 20.0, 0.01, "or_greater") var brake_sound_speed_threshold := 3.0


var move_forward := false


@onready var _crash_sound := %crash_sound
@onready var _sound_engine := %sound_engine


func _ready() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)
	if not active:
		brake = max_brake_force


func _physics_process(_delta : float) -> void:
	var was_braking := brake > 0.0

	engine_force = max_engine_force * Input.get_axis("reverse", "accelerate")
	brake = max_brake_force * Input.get_action_strength("brake")
	steering = max_steering_angle * Input.get_axis("steer_right", "steer_left")

	if engine_force > 0.0:
		move_forward = true

	if move_forward and Input.get_axis("reverse", "accelerate") < 0.0:
		brake = max_brake_force * -1.0 * Input.get_axis("reverse", "accelerate")

	var speed := linear_velocity.length()

	var is_braking := brake > 0.0
	if not was_braking and is_braking and speed >= brake_sound_speed_threshold:
		_crash_sound.play()

	if speed < 0.5:
		move_forward = false

	_sound_engine.pitch_scale = 0.5 + speed / 10.0
	_sound_engine.volume_db = -6.0 + 10.0 * speed / 10.0


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"reset_vehicle"):
		_reset()


func _reset() -> void:
	rotation = Vector3.ZERO
	global_position.y = 2.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO


func _on_body_entered(body : Node) -> void:
	if not active or body is RigidBody3D:
		return
	if linear_velocity.length() >= crash_sound_speed_threshold:
		_crash_sound.play()
