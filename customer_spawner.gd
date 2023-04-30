extends Node3D

@export_range(1.0, 100.0) var spawn_delta := 10.0
@export var customer_scene: PackedScene


var current_spawn_time := 0.0
var rng = RandomNumberGenerator.new()


func _physics_process(delta):
	current_spawn_time += delta
	if current_spawn_time > spawn_delta:
		current_spawn_time = 0.0
		var new_customer = customer_scene.instantiate()
		new_customer.position.x += rng.randf_range(-2.0, 2.0)
		new_customer.target_point = global_position
		new_customer.target_point.x += 20.0
		new_customer.target_point.z += 20.0
		var inventory := Inventory.new()
		inventory.item = GameState.FOOD_ITEMS.pick_random()
		inventory.max_quantity = 1
		new_customer.inventory = inventory

		add_child(new_customer)
