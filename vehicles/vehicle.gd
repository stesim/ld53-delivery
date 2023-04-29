extends VehicleBody3D


@export_range(0.0, 500.0, 0.01, "or_greater") var max_engine_force := 50.0
@export_range(0.0, 100.0) var max_brake_force := 1.0
@export_range(0.0, 90.0, 0.01, "radians") var max_steering_angle := 0.25 * PI


func _enter_tree() -> void:
	%inventory_indicator.inventory = %inventory.inventory


func _physics_process(_delta : float) -> void:
	engine_force = max_engine_force * Input.get_axis("reverse", "accelerate")
	brake = max_brake_force * Input.get_action_strength("brake")
	steering = max_steering_angle * Input.get_axis("steer_right", "steer_left")
