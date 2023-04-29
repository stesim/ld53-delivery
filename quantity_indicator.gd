extends Label3D


@export var inventory : Inventory


func _ready() -> void:
	inventory.changed.connect(_on_inventory_changed)
	_update()


func _on_inventory_changed() -> void:
	_update()


func _update() -> void:
	text = "%d / %d" % [inventory.quantity, inventory.max_quantity]
