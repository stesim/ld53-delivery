extends Node3D


const FoodItem := preload("res://food_item.tscn")


func _ready() -> void:
	%loading_area.backing_inventories = GameState.create_item_inventories(9999, 9999)


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"test_input"):
		var item : Node3D = FoodItem.instantiate()
		get_tree().current_scene.add_child(item)
		item.global_position = %spawn_location.global_position
