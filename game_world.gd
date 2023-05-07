extends Node3D


const MPS_TO_KMPH := 60.0 * 60.0 / 1000.0


@export var background_tracks : Array[AudioStream] = []


@onready var _revenue_label := %revenue_label
@onready var _score_sound := %score_sound
@onready var _camera := %camera
@onready var _tutorial_panels := %tutorial_panels
@onready var _speedometer := %speedometer


func _ready() -> void:
	GameState.restart()
	GameState.score_changed.connect(_on_score_changed)
	GameState.went_broke.connect(_on_broke)
	GameState.tutorial_progressed.connect(_on_tutorial_progressed)

	if not background_tracks.is_empty():
		var background_music = %background_music
		background_music.stream = background_tracks.pick_random()
		background_music.play()

	_on_score_changed(false)
	_on_tutorial_progressed()
	_swap_to_vehicle(get_tree().get_first_node_in_group(&"vehicles"))


func _physics_process(_delta : float) -> void:
	var speed : float = MPS_TO_KMPH * _camera.target.linear_velocity.length()
	_speedometer.speed = speed


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"swap_vehicle"):
		_swap_vehicle()


func _swap_vehicle() -> void:
	var vehicles := get_tree().get_nodes_in_group(&"vehicles")
	if vehicles.size() > 1:
		var current_vehicle : Node3D = _camera.target
		var next_vehicle := vehicles[(vehicles.find(current_vehicle) + 1) % vehicles.size()]
		_swap_to_vehicle(next_vehicle)


func _swap_to_vehicle(new_vehicle) -> void:
	var current_vehicle = _camera.target
	if current_vehicle:
		current_vehicle.active = false
	new_vehicle.active = true
	_camera.target = new_vehicle


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
	%broke_time_label.text = "%02d:%02d" % [minutes, seconds]
	%broke_panel.show()


func _on_tutorial_progressed() -> void:
	var step_index := int(GameState.tutorial_progress)
	for i in _tutorial_panels.get_child_count():
		_tutorial_panels.get_child(i).visible = i == step_index
