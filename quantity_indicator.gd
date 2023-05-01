extends Node3D


@export var inventory : Inventory
@export var spacing := 0.5


func _ready() -> void:
	_update_items()
	inventory.changed.connect(_update_items)


func _update_items() -> void:
	var child_count := get_child_count()
	for i in range(inventory.quantity, child_count):
		get_child(i).queue_free()
	for i in range(child_count, inventory.quantity):
		var item : Node3D = inventory.item.instantiate()
		item.position.y = i * spacing
		add_child(item)
