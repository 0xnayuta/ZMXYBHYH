extends AnimatedSprite2D
class_name AtlasMonsterVisual

signal play_end

var manifest_path: String = ""
var fps: float = 30.0
var hold_last_frame: bool = false
var _sequence: String = ""
var _looped: bool = false
var _animation_finished_connected: bool = false

func configure(manifest: String) -> void :
	manifest_path = manifest

func play_base_animation(sequence_name: String, looped: bool = true) -> bool:
	var frames: = MonsterAtlasSequence.build_sprite_frames(
		manifest_path, sequence_name, &"play", fps, looped
	)
	if frames == null or not frames.has_animation(&"play")\
	or frames.get_frame_count(&"play") == 0:
		visible = false
		return false
	sprite_frames = frames
	animation = &"play"
	frame = 0
	speed_scale = 1.0
	if not _animation_finished_connected:
		animation_finished.connect(_on_animation_finished)
		_animation_finished_connected = true
	_sequence = sequence_name
	_looped = looped
	visible = true
	play(&"play")
	return true

func is_stream_active() -> bool:
	return sprite_frames != null and sprite_frames.has_animation(animation) and is_playing()

func _on_animation_finished() -> void :
	if not _looped and hold_last_frame:
		frame = maxi(0, sprite_frames.get_frame_count(animation) - 1)
		pause()
	play_end.emit()
