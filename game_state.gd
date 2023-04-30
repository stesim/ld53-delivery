extends Node


signal score_changed()


var score := 0 :
	set(value):
		score = value
		score_changed.emit()


func _ready() -> void:
	restart()


func restart() -> void:
	score = 0


func add_score(amount : int) -> void:
	score += amount
