extends Node


func set_language(lang_code: String):
	TranslationServer.set_locale(lang_code)
	emit_signal("language_changed")
