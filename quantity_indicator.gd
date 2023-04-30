extends Node3D


@export var inventory : Inventory
@export var spacing := 0.5


func _ready() -> void:
	_update_items()
	inventory.changed.connect(_update_items)


func _update_items() -> void:
	var child_count := get_child_count()
	var diff := inventory.quantity - get_child_count()
	if diff > 0:
		for i in diff:
			var item : Node3D = inventory.item.instantiate()
			item.position.y = (i + child_count) * spacing
			add_child(item)
	elif diff < 0:
		for i in -diff:
			get_child(child_count + i - 1).queue_free()
