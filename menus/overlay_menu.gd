extends Control


@export var pause := true


var _is_ready := false


func _ready() -> void:
	_is_ready = true
	_focus_first_visible_button()
	if pause and visible:
		GameState.pause()


func _notification(what : int) -> void:
	if not _is_ready:
		return

	match what:
		NOTIFICATION_VISIBILITY_CHANGED:
			if pause:
				GameState.pause() if visible else GameState.resume()
			if visible and not get_viewport().gui_get_focus_owner():
				_focus_first_visible_button()


func _unhandled_input(event : InputEvent) -> void:
	if event.is_action_pressed(&"toggle_menu") and not event.is_echo():
		visible = !visible


func _focus_first_visible_button() -> void:
	for child in %button_list.get_children():
		if child.visible:
			child.grab_focus()
			break


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_world.tscn")


func _on_resume_button_pressed() -> void:
	hide()


func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://game_world.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
