extends Node


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
