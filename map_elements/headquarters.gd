extends Node3D


const FoodItem := preload("res://food_item.tscn")

const TRANSFER_INPUT_MAPPINGS : Array[StringName]= [
	&"transfer_item_1",
	&"transfer_item_2",
	&"transfer_item_3",
	&"transfer_item_4",
]


@export var ejection_force := 2.0


@onready var _item_spawn_locations := %item_spawn_locations
@onready var _loading_area := %loading_area


func _unhandled_input(event : InputEvent) -> void:
	if not _loading_area.has_overlapping_areas() or event.is_echo():
		return
	for i in TRANSFER_INPUT_MAPPINGS.size():
		if event.is_action_pressed(TRANSFER_INPUT_MAPPINGS[i]):
			_spawn_item(i)


func _spawn_item(index : int) -> void:
	var item := GameState.FOOD_ITEMS[index]
	var instance : RigidBody3D = FoodItem.instantiate()
	instance.item_scene = item
	instance.apply_central_impulse(ejection_force * Vector3.RIGHT)
	get_tree().current_scene.add_child(instance)
	instance.global_position = _item_spawn_locations.get_child(index).global_position
