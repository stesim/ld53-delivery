extends VehicleBody3D


@export_range(0.0, 500.0, 0.01, "or_greater") var max_engine_force := 50.0
@export_range(0.0, 100.0) var max_brake_force := 1.0
@export_range(0.0, 90.0, 0.01, "radians") var max_steering_angle := 0.25 * PI
@export_range(0.0, 200.0, 0.01, "or_greater") var inventory_loss_acceleration_threshold := 50.0
@export_range(0.0, 20.0, 0.01, "or_greater") var inventory_loss_amount := 10
@export_range(0.0, 20.0, 0.01, "or_greater") var inventory_loss_cooldown := 1.0
@export_range(0.0, 20.0, 0.01, "or_greater") var crash_sound_speed_threshold := 5.0



var _previous_speed := 0.0
var _previous_loss_time := 0


@onready var _inventory_area := %inventory
@onready var _crash_sound := %crash_sound


func _enter_tree() -> void:
	%inventory_indicator.inventory = %inventory.inventory


func _physics_process(delta : float) -> void:
	engine_force = max_engine_force * Input.get_axis("reverse", "accelerate")
	brake = max_brake_force * Input.get_action_strength("brake")
	steering = max_steering_angle * Input.get_axis("steer_right", "steer_left")
	
	var current_speed := linear_velocity.length()
	var acceleration := (current_speed - _previous_speed) / delta
	if abs(acceleration) > inventory_loss_acceleration_threshold:
		var now := Time.get_ticks_msec()
		var time_since_previous_loss := (now - _previous_loss_time) / 1000.0
		if time_since_previous_loss >= inventory_loss_cooldown:
			_inventory_area.inventory.remove(inventory_loss_amount)
			_previous_loss_time = now
	_previous_speed = current_speed


func _on_body_entered(_body : Node) -> void:
	if _previous_speed >= crash_sound_speed_threshold:
		_crash_sound.play()
