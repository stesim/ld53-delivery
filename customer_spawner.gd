extends Node3D


@export_range(1.0, 100.0) var spawn_delta := 10.0
@export_range(0.0, 10.0) var spawn_area := 2.0
@export var customer_scene: PackedScene
@export var target_shop : IceStation
@export var max_customers_alive := 20


var _timer := Timer.new()


func _ready() -> void:
	_timer.wait_time = spawn_delta
	_timer.timeout.connect(_spawn)
	_timer.autostart = true
	add_child(_timer)


func _spawn():
	if get_child_count() > max_customers_alive:
		return

	var new_customer = customer_scene.instantiate()
	new_customer.position.x += randf_range(-spawn_area, spawn_area)
	new_customer.target_point = target_shop.get_serve_location()
	new_customer.requested_item = GameState.FOOD_ITEMS.pick_random()
	add_child(new_customer)
