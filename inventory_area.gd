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


func fetch_items(item, quantity : int) -> int:
	var target_inventory := _find_item_inventory(item)
	return target_inventory.remove(quantity) if target_inventory else 0


func _find_item_inventory(item) -> Inventory:
	for inventory in inventories:
		if inventory.item == item:
			return inventory
	return null
