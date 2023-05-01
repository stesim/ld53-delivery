extends Node3D


@export var inventory : Inventory :
	set(value):
		if inventory:
			inventory.changed.disconnect(_update_items)

		inventory = value

		if not placeholder:
			_update_items()
			inventory.changed.connect(_update_items)

@export var spacing := 0.5
@export var placeholder := false
@export var bundle_size := 1


func _ready() -> void:
	if placeholder:
		add_child(inventory.item.instantiate())
	elif inventory:
		inventory = inventory


func _update_items() -> void:
	@warning_ignore("integer_division")
	var quantity := inventory.quantity / bundle_size
	var child_count := get_child_count()
	for i in range(quantity, child_count):
		get_child(i).queue_free()
	for i in range(child_count, quantity):
		var item : Node3D = inventory.item.instantiate()
		item.position.y = i * spacing
		add_child(item)
