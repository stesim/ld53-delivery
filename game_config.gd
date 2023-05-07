extends Node


const FILE_PATH := "user://config.cfg"


var master_volume := 0.5 :
	set(value):
		master_volume = value
		_set_bus_volume(_audio_bus_master, master_volume)

var music_volume := 1.0 :
	set(value):
		music_volume = value
		_set_bus_volume(_audio_bus_music, music_volume)

var sfx_volume := 1.0 :
	set(value):
		sfx_volume = value
		_set_bus_volume(_audio_bus_sfx, sfx_volume)

var fullscreen := false :
	set(value):
		if value == fullscreen:
			return
		fullscreen = value
		get_window().mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED


var _audio_bus_master := AudioServer.get_bus_index(&"Master")
var _audio_bus_music := AudioServer.get_bus_index(&"Music")
var _audio_bus_sfx := AudioServer.get_bus_index(&"SFX")


func _enter_tree() -> void:
	_read_from_disk()


func _exit_tree() -> void:
	_save_to_disk()


func _read_from_disk() -> void:
	var config := ConfigFile.new()
	config.load(FILE_PATH)

	master_volume = config.get_value("audio", "master_volume", master_volume)
	music_volume = config.get_value("audio", "music_volume", music_volume)
	sfx_volume = config.get_value("audio", "sfx_volume", sfx_volume)

	fullscreen = config.get_value("video", "fullscreen", fullscreen)


func _save_to_disk() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.set_value("video", "fullscreen", fullscreen)

	config.save(FILE_PATH)


func _set_bus_volume(bus : int, volume : float) -> void:
	var clamped := clampf(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(clamped))
	AudioServer.set_bus_mute(bus, is_zero_approx(clamped))
