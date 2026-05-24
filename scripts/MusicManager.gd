extends Node
class_name MusicManager

var music_player: AudioStreamPlayer


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	apply_music_volume()


func apply_music_volume() -> void:
	if music_player == null:
		return

	var music_bus := AudioServer.get_bus_index("Music")
	if music_bus != -1:
		AudioServer.set_bus_volume_db(music_bus, SettingsManagerLoader.get_music_volume_db())


func play_music(stream: AudioStream, restart: bool = false) -> void:
	if music_player == null or stream == null:
		return

	if music_player.stream == stream and music_player.playing and not restart:
		return

	music_player.stream = stream
	music_player.play()


func stop_music() -> void:
	if music_player != null:
		music_player.stop()
