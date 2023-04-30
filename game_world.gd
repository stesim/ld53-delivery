extends Node3D


@export var background_tracks : Array[AudioStream] = []


@onready var _revenue_label := %revenue_label
@onready var _score_sound := %score_sound


func _ready() -> void:
	GameState.score_changed.connect(_on_score_changed)
	
	if not background_tracks.is_empty():
		var background_music = %background_music
		background_music.stream = background_tracks.pick_random()
		background_music.play()


func _on_score_changed() -> void:
	_revenue_label.text = "$%d" % GameState.score
	_score_sound.stop()
	_score_sound.play()
