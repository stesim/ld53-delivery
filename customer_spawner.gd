extends Node3D

@export_range(1.0, 100.0) var spawn_delta := 10.0
@export var customer_scene: PackedScene
var current_spawn_time := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	current_spawn_time += delta
	if current_spawn_time > spawn_delta:
		current_spawn_time = 0.0
		var new_customer = customer_scene.instantiate()
		new_customer.target_point = global_position
		new_customer.target_point.z = 0.0
		add_child(new_customer)
		
