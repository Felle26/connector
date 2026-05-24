extends Node
class_name SettingsManager

var config := ConfigFile.new()
var path := "user://settings.cfg"

var language := "en"
var master_volume := 1.0
var resolution := Vector2i(1920, 1080)
var effects_volume := 1.0
var music_volume := 1.0

func _ready():
	load_settings()
	apply_audio_settings()

func load_settings():
	var err = config.load(path)
	if err != OK:
		save_settings()
		return

	language = config.get_value("general", "language", "de")
	master_volume = config.get_value("audio", "master_volume", 1.0)
	effects_volume = config.get_value("audio", "effects_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 1.0)
	resolution = config.get_value("video", "resolution", Vector2i(1920,1080))

func save_settings():
	config.set_value("general", "language", language)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "effects_volume", effects_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("video", "resolution", resolution)
	config.save(path)


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()


func set_effects_volume(value: float) -> void:
	effects_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	apply_audio_settings()
	save_settings()


func apply_audio_settings() -> void:
	var master_bus := AudioServer.get_bus_index("Master")
	if master_bus != -1:
		AudioServer.set_bus_volume_db(master_bus, get_master_volume_db())

	var effects_bus := AudioServer.get_bus_index("SFX")
	if effects_bus != -1:
		AudioServer.set_bus_volume_db(effects_bus, get_effects_volume_db())

	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, get_music_volume_db())


func get_master_volume_db() -> float:
	return linear_to_db(maxf(master_volume, 0.001))


func get_effects_volume_db() -> float:
	return linear_to_db(maxf(effects_volume, 0.001))


func get_music_volume_db() -> float:
	return linear_to_db(maxf(music_volume, 0.001))
