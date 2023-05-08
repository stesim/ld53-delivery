extends Node


const INITIAL_FUNDS := 250
const RENT_AMOUNT := 10
const RENT_INTERVAL := 10.0

const CASH_BUNDLE_SIZE := 10


const FOOD_ITEMS : Array[PackedScene] = [
	preload("res://assets/foods/iceCream.glb"),
	preload("res://assets/foods/hotDog.glb"),
	preload("res://assets/foods/burger.glb"),
	preload("res://assets/foods/soda.glb"),
]

const FOOD_PRICES : Array[int] = [
	3,
	5,
	8,
	4,
]

const CASH_ITEM := preload("res://assets/items/cash.tscn")


enum TutorialStep {
	GET_ITEMS,
	DELIVER_ITEMS,
	GET_CASH,
	DELIVER_CASH,
	COMPLETED,
}


signal score_changed()
signal went_broke()
signal tutorial_progressed()


var score := 0 :
	set(value):
		if value == score:
			return
		score = value
		var just_went_broke := score <= 0 and not is_broke
		if just_went_broke:
			is_broke = true
		score_changed.emit()
		if just_went_broke:
			went_broke.emit()

var is_broke := false

var game_time := 0.0

var tutorial_progress := TutorialStep.GET_ITEMS

var player_inputs : Array[Dictionary] = []


var _rent_timer := Timer.new()


func _ready() -> void:
	for i in FOOD_ITEMS.size():
		FOOD_ITEMS[i].set_meta(&"price", FOOD_PRICES[i])

	_rent_timer.wait_time = RENT_INTERVAL
	_rent_timer.timeout.connect(_pay_rent)
	add_child(_rent_timer)


func _physics_process(delta : float) -> void:
	game_time += delta


func restart() -> void:
	GameState.resume()
	score = INITIAL_FUNDS
	game_time = 0
	is_broke = false
	_rent_timer.stop()
	_rent_timer.start()


func pause() -> void:
	get_tree().paused = true


func resume() -> void:
	get_tree().paused = false


func add_score(amount : int) -> void:
	score += amount


func get_item_price(item) -> int:
	return item.get_meta(&"price")


func create_item_inventories(capacity : int, quantity := 0) -> Array[Inventory]:
	var inventories : Array[Inventory] = []
	for item in GameState.FOOD_ITEMS:
		var item_inventory := Inventory.new()
		item_inventory.item = item
		item_inventory.max_quantity = capacity
		item_inventory.quantity = quantity
		inventories.push_back(item_inventory)
	return inventories


func create_cash_inventory(capacity := 999999, quantity := 0) -> Inventory:
	var inventory := Inventory.new()
	inventory.item = CASH_ITEM
	inventory.max_quantity = capacity
	inventory.quantity = quantity
	return inventory


func progress_tutorial(step : TutorialStep) -> void:
	if int(step) > int(tutorial_progress) and tutorial_progress != TutorialStep.COMPLETED:
		tutorial_progress = step
		tutorial_progressed.emit()


func _pay_rent() -> void:
	score -= RENT_AMOUNT
