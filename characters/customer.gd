extends CharacterBody3D


const DEFAULT_ANIMATION_SPEED := 1.0


@export_range(0.0, 100.0) var speed := 0.5

@export var target_point := Vector3.ZERO :
	set(value):
		target_point = value
		if is_inside_tree():
			look_at(target_point)

@export var inventory : Inventory :
	set(value):
		inventory = value
		%inventory_area.inventories = [inventory] as Array[Inventory]
		%quantity_indicator.inventory = inventory


@onready var _animation_player := %AnimationPlayer


var _is_walking := false


func _ready() -> void:
	velocity = speed * global_position.direction_to(target_point)
	look_at(target_point)

	inventory.changed.connect(_on_inventory_changed)


func _physics_process(delta : float) -> void:
	var was_walking := _is_walking

	var diff_to_target := target_point - global_position
	if diff_to_target.is_zero_approx():
		_is_walking = false
	else:
		var collision := move_and_collide(diff_to_target.limit_length(delta * speed))
		_is_walking = collision == null

	if was_walking and not _is_walking:
		_animation_player.play(&"Idle")
		_animation_player.speed_scale = 1.0
	elif not was_walking and _is_walking:
		_animation_player.play(&"Forward")
		_animation_player.speed_scale = speed * DEFAULT_ANIMATION_SPEED


func _on_inventory_changed() -> void:
	if inventory.is_full():
		GameState.add_score(inventory.max_quantity * GameState.get_item_price(inventory.item))
		queue_free()
