extends Node


const FOOD_ITEMS : Array[PackedScene] = [
	preload("res://assets/foods/iceCream.glb"),
	preload("res://assets/foods/hotDog.glb"),
	preload("res://assets/foods/burger.glb"),
	preload("res://assets/foods/soda.glb"),
]


signal score_changed()


var score := 0 :
	set(value):
		score = value
		score_changed.emit()


func restart() -> void:
	GameState.resume()
	score = 0
	get_tree().change_scene_to_file("res://game_world.tscn")


func pause() -> void:
	get_tree().paused = true


func resume() -> void:
	get_tree().paused = false


func add_score(amount : int) -> void:
	score += amount


func create_item_inventories(capacity : int, quantity := 0) -> Array[Inventory]:
	var inventories : Array[Inventory] = []
	for item in GameState.FOOD_ITEMS:
		var item_inventory := Inventory.new()
		item_inventory.item = item
		item_inventory.max_quantity = capacity
		item_inventory.quantity = quantity
		inventories.push_back(item_inventory)
	return inventories
