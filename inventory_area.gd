extends Area3D


@export var total_capacity := 6
@export var inventories : Array[Inventory] = []


func get_total_quantity() -> int:
	var quantity := 0
	for inventory in inventories:
		quantity += inventory.quantity
	return quantity


func get_remaining_total_capacity() -> int:
	return maxi(0, total_capacity - get_total_quantity())
