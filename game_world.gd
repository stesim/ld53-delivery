extends Node3D


@export var background_tracks : Array[AudioStream] = []


@onready var _revenue_label := %revenue_label
@onready var _score_sound := %score_sound
@onready var _vehicle_follower := %vehicle_follower


func _ready() -> void:
	GameState.restart()
	GameState.score_changed.connect(_on_score_changed)
	GameState.went_broke.connect(_on_broke)

	if not background_tracks.is_empty():
		var background_music = %background_music
		background_music.stream = background_tracks.pick_random()
		background_music.play()

	_swap_to_vehicle(get_tree().get_first_node_in_group(&"vehicles"))

	_on_score_changed(false)


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"swap_vehicle") and not event.is_echo():
		_swap_vehicle()


func _swap_vehicle() -> void:
	var vehicles := get_tree().get_nodes_in_group(&"vehicles")
	if vehicles.size() > 1:
		var current_vehicle : Node3D = _vehicle_follower.target
		var next_vehicle := vehicles[(vehicles.find(current_vehicle) + 1) % vehicles.size()]
		_swap_to_vehicle(next_vehicle)


func _swap_to_vehicle(new_vehicle) -> void:
	var current_vehicle = _vehicle_follower.target
	if current_vehicle:
		current_vehicle.active = false
	new_vehicle.active = true
	_vehicle_follower.target = new_vehicle


func _on_score_changed(play_sound := true) -> void:
	var score := GameState.score
	_revenue_label.text = "$%d" % score if score >= 0 else "-$%d" % -score
	if play_sound:
		_score_sound.play()


func _on_broke() -> void:
	var broke_time := roundi(GameState.game_time)
	@warning_ignore("integer_division")
	var minutes := broke_time / 60
	var seconds := broke_time % 60
	%broke_time_label.text = "%d:%d" % [minutes, seconds]
	%broke_panel.show()
