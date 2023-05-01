extends VehicleBody3D


@export var active := false :
	set(value):
		active = value
		set_physics_process(active)
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


var _previous_speed := 0.0
var _previous_loss_time := 0
var move_forward := false


@onready var _inventory_area := %inventory_area
@onready var _crash_sound := %crash_sound
@onready var _sound_engine := %sound_engine


func _ready() -> void:
	set_physics_process(false)
	if not active:
		brake = max_brake_force


func _enter_tree() -> void:
	var inventory_area := %inventory_area
	var inventories := GameState.create_item_inventories(inventory_area.total_capacity)
	inventory_area.inventories = inventories
	%inventory_indicator.inventories = inventory_area.inventories


func _physics_process(delta : float) -> void:
	var was_braking := brake > 0.0

	engine_force = max_engine_force * Input.get_axis("reverse", "accelerate")
	brake = max_brake_force * Input.get_action_strength("brake")
	steering = max_steering_angle * Input.get_axis("steer_right", "steer_left")
	
	if engine_force > 0.0:
		move_forward = true
	
	if move_forward and Input.get_axis("reverse", "accelerate") < 0.0:
		brake = max_brake_force * -1.0 * Input.get_axis("reverse", "accelerate")
	
	var is_braking := brake > 0.0
	if not was_braking and is_braking and _previous_speed >= brake_sound_speed_threshold:
		_crash_sound.play()

	var current_speed := linear_velocity.length()
	var acceleration := (current_speed - _previous_speed) / delta
	
	if current_speed < 0.5:
		move_forward = false

	_sound_engine.pitch_scale = 0.5 + current_speed / 10.0
	_sound_engine.volume_db = -6.0 + 10.0 * current_speed / 10.0
	
	if abs(acceleration) > inventory_loss_acceleration_threshold:
		var now := Time.get_ticks_msec()
		var time_since_previous_loss := (now - _previous_loss_time) / 1000.0
		if time_since_previous_loss >= inventory_loss_cooldown:
			_lose_inventory(inventory_loss_amount)
			_previous_loss_time = now
	_previous_speed = current_speed


func _lose_inventory(quantity : int) -> void:
	var inventories : Array[Inventory] = _inventory_area.inventories
	for inventory in inventories:
		quantity -= inventory.remove(quantity)
		if quantity == 0:
			break


func _on_body_entered(body : Node) -> void:
	if not active or body is RigidBody3D:
		return
	if _previous_speed >= crash_sound_speed_threshold:
		_crash_sound.play()
