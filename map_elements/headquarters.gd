extends Node3D


func _ready() -> void:
	%loading_area.backing_inventories = GameState.create_item_inventories(9999, 9999)
