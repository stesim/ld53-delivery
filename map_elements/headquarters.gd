extends Node3D


const FoodItem := preload("res://food_item.tscn")
const CashItem := preload("res://assets/items/cash.tscn")

const TRANSFER_INPUT_MAPPINGS : Array[StringName]= [
	&"transfer_item_1",
	&"transfer_item_2",
	&"transfer_item_3",
	&"transfer_item_4",
]


@export var ejection_force := 2.0


@onready var _item_spawn_locations := %item_spawn_locations


func spawn_item(item) -> void:
	_spawn_item(GameState.FOOD_ITEMS.find(item))
	GameState.progress_tutorial(GameState.TutorialStep.DELIVER_ITEMS)


func take_cash(amount : int) -> void:
	GameState.add_score(amount)
	GameState.progress_tutorial(GameState.TutorialStep.COMPLETED)


func _spawn_item(index : int) -> void:
	var item := GameState.FOOD_ITEMS[index]
	var instance : RigidBody3D = FoodItem.instantiate()
	instance.item_scene = item
	instance.apply_central_impulse(ejection_force * Vector3.RIGHT)
	get_tree().current_scene.add_child(instance)
	instance.rotation = TAU * Vector3(randf(), randf(), randf())
	var spawn_location := _item_spawn_locations.get_child(index)
	instance.global_position = spawn_location.global_position
	var sound := spawn_location.get_child(0)
	sound.play()
