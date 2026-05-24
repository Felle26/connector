extends Control
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():

	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	 # Sprache
	TranslationServer.set_locale(SettingsManagerLoader.language)
	$CenterContainer/VBoxContainer/PlayButton.text = tr("MENU_PLAY")
	$CenterContainer/VBoxContainer/OptionsButton.text = tr("MENU_OPTIONS")
	$CenterContainer/VBoxContainer/QuitButton.text = tr("MENU_QUIT")

	# Lautstärke
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(SettingsManagerLoader.master_volume)
	)

	# Auflösung
	DisplayServer.window_set_size(SettingsManagerLoader.resolution)
	print("Current Res:", SettingsManagerLoader.resolution)

func _on_play_pressed():
	get_tree().change_scene_to_file("res://lvl/grid_level.tscn")


func _on_options_pressed():
	get_tree().change_scene_to_file("res://menu/main/options.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _on_Button_Click_audio():
	audio_stream_player.volume_db = linear_to_db(SettingsManagerLoader.effects_volume*SettingsManagerLoader.master_volume)
	audio_stream_player.play()
