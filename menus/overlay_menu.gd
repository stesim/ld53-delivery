extends Control


@export var pause := true


var _is_ready := false


@onready var _master_volume_slider : Slider = %master_volume_slider
@onready var _music_volume_slider : Slider = %music_volume_slider
@onready var _sfx_volume_slider : Slider = %sfx_volume_slider
@onready var _fullscreen_checkbox : CheckBox = %fullscreen_checkbox
@onready var _credits_text_box : TextEdit = %credits_text_box


func _ready() -> void:
	_is_ready = true
	_focus_first_visible_button()
	if pause and visible:
		GameState.pause()

	_fullscreen_checkbox.button_pressed = GameConfig.fullscreen
	_master_volume_slider.value = GameConfig.master_volume
	_music_volume_slider.value = GameConfig.music_volume
	_sfx_volume_slider.value = GameConfig.sfx_volume

	_load_credits()


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
	get_tree().change_scene_to_file("res://game_scenes/single_player.tscn")


func _on_play_split_screen_pressed() -> void:
	get_tree().change_scene_to_file("res://game_scenes/split_screen.tscn")


func _on_resume_button_pressed() -> void:
	hide()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_volume_slider_value_changed(value : float) -> void:
	GameConfig.master_volume = value


func _on_music_volume_slider_value_changed(value : float) -> void:
	GameConfig.music_volume = value


func _on_sfx_volume_slider_value_changed(value : float) -> void:
	GameConfig.sfx_volume = value


func _on_fullscreen_checkbox_toggled(button_pressed : bool) -> void:
	GameConfig.fullscreen = button_pressed


func _on_credits_button_toggled(button_pressed : bool) -> void:
	_credits_text_box.visible = button_pressed


func _load_credits() -> void:
	var license_text = FileAccess.get_file_as_string("res://license/license.txt")
	_credits_text_box.text += license_text
