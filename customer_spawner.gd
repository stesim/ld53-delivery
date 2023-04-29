extends Node3D

@export_range(1.0, 100.0) var spawn_delta := 10.0
@export var customer_scene: PackedScene
@export var min_capacity := 3
@export var max_capacity := 8


var current_spawn_time := spawn_delta

func _physics_process(delta):
	current_spawn_time += delta
	if current_spawn_time > spawn_delta:
		current_spawn_time = 0.0
		var new_customer = customer_scene.instantiate()
		new_customer.target_point = global_position
		new_customer.target_point.z = 0.0
		var inventory := Inventory.new()
		inventory.max_quantity = randi_range(min_capacity, max_capacity)
		new_customer.inventory = inventory

		add_child(new_customer)
