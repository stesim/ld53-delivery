class_name Inventory
extends Resource


@export var item : PackedScene = null

@export var quantity := 0 :
	set(value):
		quantity = value
		changed.emit()

@export var max_quantity := 50


func add(amount : int) -> int:
	var diff = mini(amount, remaining_capacity())
	quantity += diff
	return diff


func remove(amount : int) -> int:
	var diff := mini(amount, quantity)
	quantity -= diff
	return diff


func remaining_capacity() -> int:
	return max_quantity - quantity


func is_empty() -> bool:
	return quantity == 0


func is_full() -> bool:
	return quantity == max_quantity
