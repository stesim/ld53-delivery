extends Node3D


const QuantityIndicator := preload("res://quantity_indicator.tscn")


@export var inventories : Array[Inventory] = [] :
	set(value):
		inventories = value
		if is_inside_tree():
			_recreate_indicators()

@export_range(0.0, 1.0) var spacing := 0.5


func _ready() -> void:
	_recreate_indicators()


func _recreate_indicators() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for i in inventories.size():
		var quantity_indicator := QuantityIndicator.instantiate()
		quantity_indicator.inventory = inventories[i]
		quantity_indicator.position.x = -(i * spacing - 0.5 * (inventories.size() - 1) * spacing)
		add_child(quantity_indicator)
