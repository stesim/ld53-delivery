extends Label3D


@export var inventory : Inventory


func _ready() -> void:
	text = str(inventory.quantity)
	inventory.changed.connect(_on_inventory_changed)


func _on_inventory_changed() -> void:
	text = str(inventory.quantity)
