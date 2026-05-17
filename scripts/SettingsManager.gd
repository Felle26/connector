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
