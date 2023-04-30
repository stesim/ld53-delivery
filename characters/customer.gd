extends Node3D


const DEFAULT_ANIMATION_SPEED := 1.0


@export_range(0.0, 100.0) var speed := 0.5

@export var target_point := Vector3.ZERO :
	set(value):
		target_point = value
		if is_inside_tree():
			look_at(target_point)

@export var inventory : Inventory :
	set(value):
		inventory = value
		%inventory_area.inventory = inventory
		%quantity_indicator.inventory = inventory


@onready var _animation_player := %AnimationPlayer


var _is_walking := false
var _init_scale : float
var _speed_rand : float


func _ready() -> void:
	look_at(target_point)
	_init_scale = float(inventory.max_quantity) / 5.0
	scale = Vector3(_init_scale, _init_scale, _init_scale)
	_speed_rand = randf_range(0.5, 2.0)
	


func _physics_process(delta : float) -> void:
	var previous_position := global_position
	global_position = global_position.move_toward(target_point, delta * speed * _speed_rand)

	var scale_factor = _init_scale * (1.0 - float(inventory.quantity) / float(inventory.max_quantity))
	if is_zero_approx(scale_factor):
		GameState.add_score(inventory.max_quantity)
		queue_free()
		return
	
	scale = Vector3(scale_factor, scale_factor, scale_factor)
	
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
