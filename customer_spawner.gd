extends Node3D


@export_range(1.0, 100.0) var spawn_delta := 10.0
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
	new_customer.position.x += randf_range(-2.0, 2.0)
	new_customer.target_point = target_shop.get_serve_location()
	var inventory := Inventory.new()
	inventory.item = GameState.FOOD_ITEMS.pick_random()
	inventory.max_quantity = 1
	new_customer.inventory = inventory
	add_child(new_customer)
