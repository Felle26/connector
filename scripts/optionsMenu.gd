extends Control
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	# tranlation
	$MarginContainer/VBoxContainer/Label.text = tr("MENU_OPTIONS_TITLE")
	$MarginContainer/VBoxContainer/HBoxContainer/Label.text = tr("MENU_OPTIONS_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer4/Label.text = tr("MENU_OPTIONS_EFFECT_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer5/Label.text = tr("MENU_OPTIONS_MUSIC_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer2/Label.text = tr("MENU_OPTIONS_RESOLUTION")
	$MarginContainer/VBoxContainer/HBoxContainer3/Label.text = tr("MENU_OPTIONS_LANGUAGE")
	$MarginContainer/VBoxContainer/BackButton.text = tr("MENU_OPTIONS_BACK")
	$MarginContainer/VBoxContainer/HBoxContainer3/Deutsch.text = tr("MENU_OPTIONS_LANG_GERMAN")
	$MarginContainer/VBoxContainer/HBoxContainer3/Englisch.text = tr("MENU_OPTIONS_LANG_ENGLISH")
	$MarginContainer/VBoxContainer/HBoxContainer3/Deutsch.pressed.connect(_on_language_de_pressed)
	$MarginContainer/VBoxContainer/HBoxContainer3/Englisch.pressed.connect(_on_language_en_pressed)
	# Volume
	# load settings
	$MarginContainer/VBoxContainer/HBoxContainer/VolumeSlider.value = SettingsManagerLoader.master_volume
	$MarginContainer/VBoxContainer/HBoxContainer4/VolumeSlider.value = SettingsManagerLoader.effects_volume
	$MarginContainer/VBoxContainer/HBoxContainer5/VolumeSlider.value = SettingsManagerLoader.music_volume
	var res_button = $MarginContainer/VBoxContainer/HBoxContainer2/ResolutionButton
	var current_res = SettingsManagerLoader.resolution
	for i in range(res_button.item_count):
		if res_button.get_item_text(i) == str(current_res.x) + "x" + str(current_res.y):
			res_button.select(i)
			break
	
	if SettingsManagerLoader.language == "de":
		$MarginContainer/VBoxContainer/HBoxContainer3/Deutsch.disabled = false
		$MarginContainer/VBoxContainer/HBoxContainer3/Englisch.disabled = false
	else:
		$MarginContainer/VBoxContainer/HBoxContainer3/Deutsch.disabled = false
		$MarginContainer/VBoxContainer/HBoxContainer3/Englisch.disabled = false
	$MarginContainer/VBoxContainer/HBoxContainer/VolumeSlider.value_changed.connect(_on_volume_changed)
	$MarginContainer/VBoxContainer/HBoxContainer4/VolumeSlider.value_changed.connect(_on_effect_Volume_changed)
	$MarginContainer/VBoxContainer/HBoxContainer5/VolumeSlider.value_changed.connect(_on_music_Volume_changed)
	# Resolution
	LanguageManagerLoader.language_changed.connect(_on_language_changed)
	res_button.add_item("1280x720")
	res_button.add_item("1920x1080")
	res_button.add_item("2560x1440")
	res_button.item_selected.connect(_on_resolution_selected)

	# Back
	$MarginContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)


func _on_volume_changed(value):
	SettingsManagerLoader.set_master_volume(value)

func _on_effect_Volume_changed(value):
	SettingsManagerLoader.set_effects_volume(value)

func _on_music_Volume_changed(value):
	SettingsManagerLoader.set_music_volume(value)

func _on_resolution_selected(index):
	var res_button = $MarginContainer/VBoxContainer/HBoxContainer2/ResolutionButton
	var text = res_button.get_item_text(index)
	var parts = text.split("x")
	var res = Vector2i(parts[0].to_int(), parts[1].to_int())
	DisplayServer.window_set_size(res)
	
	SettingsManagerLoader.resolution = res
	SettingsManagerLoader.save_settings()


func _on_language_de_pressed():
	LanguageManagerLoader.set_language("de")

func _on_language_en_pressed():
	LanguageManagerLoader.set_language("en")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://menu/main/mainmenu.tscn")

func _on_language_changed(new_locale):
	$MarginContainer/VBoxContainer/Label.text = tr("MENU_OPTIONS_TITLE")
	$MarginContainer/VBoxContainer/HBoxContainer/Label.text = tr("MENU_OPTIONS_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer4/Label.text = tr("MENU_OPTIONS_EFFECT_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer5/Label.text = tr("MENU_OPTIONS_MUSIC_VOLUME")
	$MarginContainer/VBoxContainer/HBoxContainer2/Label.text = tr("MENU_OPTIONS_RESOLUTION")
	$MarginContainer/VBoxContainer/HBoxContainer3/Label.text = tr("MENU_OPTIONS_LANGUAGE")
	$MarginContainer/VBoxContainer/BackButton.text = tr("MENU_OPTIONS_BACK")
	$MarginContainer/VBoxContainer/HBoxContainer3/Deutsch.text = tr("MENU_OPTIONS_LANG_GERMAN")
	$MarginContainer/VBoxContainer/HBoxContainer3/Englisch.text = tr("MENU_OPTIONS_LANG_ENGLISH")


func _on_Button_Clicked():
	audio_stream_player.play()
