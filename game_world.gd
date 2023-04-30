extends Node3D


@onready var _revenue_label := %revenue_label
@onready var _score_sound := %score_sound


func _ready() -> void:
	GameState.score_changed.connect(_on_score_changed)


func _on_score_changed() -> void:
	_revenue_label.text = "$%d" % GameState.score
	_score_sound.stop()
	_score_sound.play()
