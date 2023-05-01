class_name IceStation
extends Node3D


const CashItem := preload("res://assets/items/cash.tscn")
const CashBundle := preload("res://cash_bundle.tscn")


@export var item_capacity := 25
@export var cash_ejection_force := 4.0
@export var cash_item_scene : PackedScene
@export var cash_instance_scene : PackedScene


var _inventories : Array[Inventory]
var _cash_inventory := GameState.create_cash_inventory()


@onready var _loading_area := %loading_area
@onready var _feeding_area := %feeding_area
@onready var _cash_spawn_location := %cash_spawn_location


func _ready() -> void:
	_inventories = GameState.create_item_inventories(item_capacity)

	_loading_area.backing_inventories = _inventories
	%inventory_indicator.inventories = _inventories
	_feeding_area.backing_inventories = _inventories

	%cash_indicator.bundle_size = GameState.CASH_BUNDLE_SIZE
	%cash_indicator.inventory = _cash_inventory


func get_serve_location() -> Vector3:
	return _feeding_area.global_position


func _unhandled_input(event : InputEvent) -> void:
	if not _loading_area.has_overlapping_areas():
		return
	if event.is_action_pressed(&"transfer_cash"):
		_extract_cash()


func _extract_cash() -> void:
	if _cash_inventory.quantity < GameState.CASH_BUNDLE_SIZE:
		return
	_cash_inventory.remove(GameState.CASH_BUNDLE_SIZE)
	_spawn_cash()


func _spawn_cash() -> void:
	var instance : RigidBody3D = CashBundle.instantiate()
	instance.apply_central_impulse(cash_ejection_force * (basis * Vector3(0.0, 0.0, 1.0)))
	get_tree().current_scene.add_child(instance)
	instance.global_transform = _cash_spawn_location.global_transform


func _on_serve_timer_timeout() -> void:
	for item in GameState.FOOD_ITEMS:
		_feeding_area.transfer(item)


func _on_feeding_area_items_transferred(item, quantity : int) -> void:
	_cash_inventory.add(quantity * GameState.get_item_price(item))
