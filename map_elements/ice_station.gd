class_name IceStation
extends Node3D


const CashItem := preload("res://assets/items/cash.tscn")
const CashBundle := preload("res://cash_bundle.tscn")


@export var item_capacity := 25
@export var cash_ejection_force := 0.0
@export var cash_item_scene : PackedScene
@export var cash_instance_scene : PackedScene


var _inventories : Array[Inventory]
var _cash_inventory := GameState.create_cash_inventory()


@onready var _feeding_area := %feeding_area
@onready var _cash_indicator := %cash_indicator
@onready var _item_sounds := %item_sounds


func _ready() -> void:
	_inventories = GameState.create_item_inventories(item_capacity)

	%inventory_indicator.inventories = _inventories
	_feeding_area.backing_inventories = _inventories

	_cash_indicator.bundle_size = GameState.CASH_BUNDLE_SIZE
	_cash_indicator.inventory = _cash_inventory


func get_serve_location() -> Vector3:
	return _feeding_area.global_position


func take_food(item, amount : int) -> int:
	var transferred_amount := 0
	for inventory in _inventories:
		if inventory.item == item:
			transferred_amount = inventory.add(amount)
			break

	if transferred_amount > 0:
		_item_sounds.get_child(GameState.FOOD_ITEMS.find(item)).play()
		GameState.progress_tutorial(GameState.TutorialStep.GET_CASH)

	return transferred_amount


func extract_cash() -> bool:
	if _cash_inventory.quantity < GameState.CASH_BUNDLE_SIZE:
		return false
	_cash_inventory.remove(GameState.CASH_BUNDLE_SIZE)
	_spawn_cash()

	GameState.progress_tutorial(GameState.TutorialStep.DELIVER_CASH)
	return true


func _spawn_cash() -> void:
	var instance : RigidBody3D = CashBundle.instantiate()
	instance.apply_central_impulse(cash_ejection_force * (basis * Vector3(0.0, 0.0, 1.0)))
	get_tree().current_scene.add_child(instance)
	instance.global_transform = _cash_indicator.global_transform


func _on_serve_timer_timeout() -> void:
	for item in GameState.FOOD_ITEMS:
		_feeding_area.transfer(item)


func _on_feeding_area_items_transferred(item, quantity : int) -> void:
	_cash_inventory.add(quantity * GameState.get_item_price(item))
