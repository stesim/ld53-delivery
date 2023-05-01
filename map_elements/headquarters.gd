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

@onready var _ice_cream_sound := %ice_cream_sound
@onready var _hotdog_sound := %hot_dog_sound
@onready var _burger_sound := %burger_sound
@onready var _drink_sound := %drink_sound


func _unhandled_input(event : InputEvent) -> void:
	if not _loading_area.has_overlapping_areas() or event.is_echo():
		return
	for i in TRANSFER_INPUT_MAPPINGS.size():
		if event.is_action_pressed(TRANSFER_INPUT_MAPPINGS[i]):
			_spawn_item(i)
			match i:
				0: _ice_cream_sound.play()
				1: _hotdog_sound.play()
				2: _burger_sound.play()
				3: _drink_sound.play()


func _spawn_item(index : int) -> void:
	var item := GameState.FOOD_ITEMS[index]
	var instance : RigidBody3D = FoodItem.instantiate()
	instance.item_scene = item
	instance.apply_central_impulse(ejection_force * Vector3.RIGHT)
	get_tree().current_scene.add_child(instance)
	instance.global_position = _item_spawn_locations.get_child(index).global_position
