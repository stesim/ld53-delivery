extends Area3D


enum Type {
	SOURCE,
	SINK,
}


const TRANSFER_INPUT_MAPPINGS : Array[StringName]= [
	&"transfer_item_1",
	&"transfer_item_2",
	&"transfer_item_3",
	&"transfer_item_4",
]


@export var type := Type.SOURCE
@export var backing_inventories : Array[Inventory] = []

@export var quantity_per_tick := 1
@export var player_controlled := false


func _ready() -> void:
	set_process_unhandled_input(player_controlled)


func _unhandled_input(event : InputEvent) -> void:
	if event.is_echo():
		return
	for i in TRANSFER_INPUT_MAPPINGS.size():
		if event.is_action_pressed(TRANSFER_INPUT_MAPPINGS[i]):
			var item := GameState.FOOD_ITEMS[i]
			transfer(item)


func transfer(item) -> void:
	if not has_overlapping_areas():
		return
	var backing_inventory := _find_item_inventory(backing_inventories, item)
	match type:
		Type.SOURCE: _transfer_to_inventories(backing_inventory)
		Type.SINK: _transfer_from_inventories(backing_inventory)


func _transfer_to_inventories(backing_inventory : Inventory) -> void:
	if backing_inventory.is_empty():
		return
	for area in get_overlapping_areas():
		var quantity := mini(
			mini(quantity_per_tick, backing_inventory.quantity),
			area.get_remaining_total_capacity(),
		)
		if quantity == 0:
			break
		var target_inventory := _find_item_inventory(area.inventories, backing_inventory.item)
		if target_inventory:
			var diff : int = target_inventory.add(quantity)
			backing_inventory.remove(diff)


func _transfer_from_inventories(backing_inventory : Inventory) -> void:
	if backing_inventory.is_full():
		return
	for area in get_overlapping_areas():
		var quantity := mini(quantity_per_tick, backing_inventory.remaining_capacity())
		if quantity == 0:
			break
		var target_inventory := _find_item_inventory(area.inventories, backing_inventory.item)
		if target_inventory:
			var diff : int = target_inventory.remove(quantity)
			backing_inventory.add(diff)


func _find_item_inventory(inventories : Array[Inventory], item) -> Inventory:
	for inventory in inventories:
		if inventory.item == item:
			return inventory
	return null
