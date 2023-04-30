extends "res://inventory_area.gd"


func fetch_items(item, amount : int) -> int:
	if amount <= 0:
		return 0
	var contained_amount := 0
	for contained_item in get_overlapping_bodies():
		if contained_item.item_scene != item:
			continue
		contained_item.queue_free()
		contained_amount += 1
		if contained_amount == amount:
			break
	return contained_amount
