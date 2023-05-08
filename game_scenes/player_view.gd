extends Node3D


const TrackingCamera := preload("res://tracking_camera.gd")


const MPS_TO_KMPH := 60.0 * 60.0 / 1000.0


@export var player_index := 0 :
	set(value):
		player_index = value
		if is_inside_tree():
			get_viewport().set_meta(&"_player_index", player_index)


@onready var _camera : TrackingCamera = %camera
@onready var _hud := %hud


var _input_map := {}
var _controlled_vehicle : Vehicle = null


func _ready() -> void:
	player_index = player_index

	var device_type := PlayerInput.DeviceType.ANY
	if player_index > 0:
		device_type = PlayerInput.DeviceType.CONTROLLER
	elif player_index == 0:
		device_type = PlayerInput.DeviceType.KEYBOARD
	var device_index := player_index if player_index < 1 else player_index - 1

	_input_map = PlayerInput.create_map(player_index, device_type, device_index)

	_camera.input_map = _input_map
	_swap_vehicle()
	_camera.snap_to_target()


func _exit_tree() -> void:
	PlayerInput.remove_map(_input_map)


func _physics_process(_delta : float) -> void:
	var speed : float = MPS_TO_KMPH * _camera.target.get_speed()
	_hud.speed = speed


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(_input_map.swap_vehicle):
		_swap_vehicle()


func _swap_vehicle() -> void:
	var vehicles := get_tree().get_nodes_in_group(&"vehicles")
	if vehicles.size() < 2:
		return
	var start_index := vehicles.find(_controlled_vehicle) + 1
	for i in vehicles.size():
		var next_vehicle := vehicles[(start_index + i) % vehicles.size()]
		if not next_vehicle.is_controlled():
			_swap_to_vehicle(next_vehicle)
			break


func _swap_to_vehicle(new_vehicle) -> void:
	var current_vehicle = _camera.target
	if new_vehicle == current_vehicle:
		return
	if current_vehicle:
		current_vehicle.controlling_player_index = -1
		current_vehicle.input_map = {}
	new_vehicle.controlling_player_index = maxi(0, player_index)
	new_vehicle.input_map = _input_map
	_controlled_vehicle = new_vehicle
	_camera.target = _controlled_vehicle
