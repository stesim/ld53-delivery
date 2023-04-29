extends Area3D


enum Type {
	SOURCE,
	SINK,
}


@export var type := Type.SOURCE
@export var backing_inventory : Inventory
@export var tick_interval := 1.0 :
	set(value):
		tick_interval = value
		%load_timer.wait_time = value

@export var quantity_per_tick := 1


func _on_load_timer_timeout() -> void:
	if not has_overlapping_areas():
		return

	match type:
		Type.SOURCE: _transfer_to_inventories()
		Type.SINK: _transfer_from_inventories()


func _transfer_to_inventories() -> void:
	if backing_inventory.is_empty():
		return
	for area in get_overlapping_areas():
		var quantity := mini(quantity_per_tick, backing_inventory.quantity)
		if quantity == 0:
			break
		var diff : int = area.inventory.add(quantity)
		backing_inventory.remove(diff)


func _transfer_from_inventories() -> void:
	if backing_inventory.is_full():
		return
	for area in get_overlapping_areas():
		var quantity := mini(quantity_per_tick, backing_inventory.remaining_capacity())
		if quantity == 0:
			break
		var diff : int = area.inventory.remove(quantity)
		backing_inventory.add(diff)
