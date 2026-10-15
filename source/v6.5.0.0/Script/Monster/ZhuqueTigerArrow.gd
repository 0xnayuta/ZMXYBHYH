extends MonsterBullet

const FRAME_ROOT: = "res://Art/Monster/SwfPng/3002/arrow"
const ATLAS_MANIFEST: = "res://Art/Monster/SwfPng/3002/atlas/manifest.json"
const FRAME_COUNT: = 8
const SOURCE_FPS: = 30.0

static var _frames_cache: SpriteFrames
var _move_speed: = 650.0

func _ready() -> void :
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.play(&"fly")
	middle.scale.x = 1.0 if dir else -1.0
	hit_box.area_entered.connect(_on_arrow_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(2.5)

func _physics_process(delta: float) -> void :
	global_position.x += (1.0 if dir else -1.0) * _move_speed * delta

func _on_arrow_area_entered(area: Area2D) -> void :
	super._on_hit_box_area_entered(area)
	queue_free()

static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames: = SpriteFrames.new()
	frames.remove_animation(&"default")
	if ResourceLoader.exists(ATLAS_MANIFEST):
		MonsterAtlasSequence.add_animation(frames, ATLAS_MANIFEST, "arrow", &"fly", SOURCE_FPS, true)
		_frames_cache = frames
		return frames
	frames.add_animation(&"fly")
	frames.set_animation_loop(&"fly", true)
	frames.set_animation_speed(&"fly", SOURCE_FPS)
	for index in range(1, FRAME_COUNT + 1):
		var texture: = Global.get_cached_texture(FRAME_ROOT.path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"fly", texture)
	_frames_cache = frames
	return frames
