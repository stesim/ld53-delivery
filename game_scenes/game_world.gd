extends Node3D


const MPS_TO_KMPH := 60.0 * 60.0 / 1000.0


@export var background_tracks : Array[AudioStream] = []


@onready var _score_sound := %score_sound


func _ready() -> void:
	GameState.restart()
	GameState.score_changed.connect(_score_sound.play)

	if not background_tracks.is_empty():
		var background_music = %background_music
		background_music.stream = background_tracks.pick_random()
		background_music.play()
