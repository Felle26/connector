# File: res://scripts/LanguageManager.gd
extends Node
class_name LanguageManager

signal language_changed(new_locale)

var current_locale: String = ""

func _ready():
	# Set default language on startup
	current_locale = SettingsManagerLoader.language
	TranslationServer.set_locale(current_locale)
	call_deferred("emit_signal", "language_changed", current_locale)


func set_language(locale: String):
	if locale == current_locale:
		return

	current_locale = locale
	SettingsManagerLoader.language = locale
	SettingsManagerLoader.save_settings()
	TranslationServer.set_locale(locale)

	# Notify all UI elements
	emit_signal("language_changed", locale)


func get_available_languages() -> Array:
	var langs := []
	for t in TranslationServer.get_loaded_locales():
		langs.append(t)
	return langs
