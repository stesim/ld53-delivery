extends Control


@export var pause := true


var _is_ready := false
var _audio_bus_index := AudioServer.get_bus_index(&"Master")


@onready var _volume_slider : Slider = %volume_slider
@onready var _fullscreen_checkbox : CheckBox = %fullscreen_checkbox


func _ready() -> void:
	_is_ready = true
	_focus_first_visible_button()
	if pause and visible:
		GameState.pause()

	_fullscreen_checkbox.button_pressed = get_window().mode == Window.MODE_FULLSCREEN
	_volume_slider.value = 100.0 * db_to_linear(AudioServer.get_bus_volume_db(_audio_bus_index))


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


func _on_volume_slider_value_changed(value : float) -> void:
	if is_zero_approx(value):
		AudioServer.set_bus_mute(_audio_bus_index, true)
	else:
		AudioServer.set_bus_mute(_audio_bus_index, false)
		var linear := value / 100.0
		AudioServer.set_bus_volume_db(_audio_bus_index, linear_to_db(linear))


func _on_fullscreen_checkbox_toggled(button_pressed : bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if button_pressed else Window.MODE_WINDOWED
