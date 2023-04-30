class_name IceStation
extends Node3D


@export var item_capacity := 25


var _inventories : Array[Inventory]


@onready var _feeding_area := %feeding_area


func _ready() -> void:
	_inventories = GameState.create_item_inventories(item_capacity)

	%loading_area.backing_inventories = _inventories
	%inventory_indicator.inventories = _inventories
	_feeding_area.backing_inventories = _inventories


func get_serve_location() -> Vector3:
	return _feeding_area.global_position


func _on_serve_timer_timeout() -> void:
	for item in GameState.FOOD_ITEMS:
		_feeding_area.transfer(item)
