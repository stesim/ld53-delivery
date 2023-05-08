extends Control


var speed := 0.0 :
	set(value):
		speed = value
		if _speedometer:
			_speedometer.speed = speed


@onready var _speedometer := %speedometer
@onready var _revenue_label := %revenue_label
@onready var _tutorial_panels := %tutorial_panels


func _ready() -> void:
	GameState.score_changed.connect(_on_score_changed)
	GameState.went_broke.connect(_on_broke)
	GameState.tutorial_progressed.connect(_on_tutorial_progressed)

	speed = speed

	_on_score_changed()
	_on_tutorial_progressed()


func _on_score_changed() -> void:
	var score := GameState.score
	_revenue_label.text = "$%d" % score if score >= 0 else "-$%d" % -score


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
