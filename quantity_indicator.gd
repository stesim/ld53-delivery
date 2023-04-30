extends Label3D


@export var inventory : Inventory


func _ready() -> void:
	var item := inventory.item.instantiate()
	%item_location.add_child(item)

	inventory.changed.connect(_on_inventory_changed)
	_update()


func _on_inventory_changed() -> void:
	_update()


func _update() -> void:
	text = str(inventory.quantity)
