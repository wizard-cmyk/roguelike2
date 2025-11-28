class_name SFX
extends RefCounted

const DEFAULT_VOLUME: float = 1.0

var audio: AudioStreamPlayer2D

func _init() -> void:
	audio = AudioStreamPlayer2D.new()
	audio.finished.connect(reset)

func play_sfx(_sound: String, _volume: float = 1.0, _from: float = 0.0) -> void:
	audio.stream = load(_sound)
	audio.volume_db = _volume
	audio.play(_from)

func reset() -> void:
	audio.stream = null
	audio.volume_db = DEFAULT_VOLUME
