extends MonsterBullet

@export var arrow_kind: = 1
const ROOT: = "res://Art/Monster/SwfPng/3020"
const ATLAS_MANIFEST: = ROOT + "/atlas/manifest.json"
const VISUAL_OFFSETS: = {
	1: Vector2(-11.0, -2.5), 
	2: Vector2(-8.475, -5.45), 
}
static var _frames_cache: Dictionary = {}
var _direction: = Vector2.RIGHT
var _speed: = 80.0

static func prewarm_frames() -> void :
	var tree: = Engine.get_main_loop() as SceneTree
	for kind in [1, 2]:
		if not _frames_cache.has(kind):
			_frames_cache[kind] = _build_frames(kind)
			if tree != null:
				await tree.process_frame

func set_direction_vector(direction: Vector2, speed_: float) -> void :
	_direction = direction
	_speed = speed_
	if is_node_ready():
		middle.rotation = _direction.angle()

func _ready() -> void :
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _frames_for_kind(arrow_kind)
	bullet_ani.position = VISUAL_OFFSETS[arrow_kind]
	bullet_ani.play(&"fly");middle.rotation = _direction.angle()
	hit_box.area_entered.connect(_on_arrow_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(5.0)

func _frames_for_kind(kind: int) -> SpriteFrames:
	if not _frames_cache.has(kind):
		_frames_cache[kind] = _build_frames(kind)
	return _frames_cache[kind] as SpriteFrames

static func _build_frames(kind: int) -> SpriteFrames:
	var folder: = "arrow1" if kind == 1 else "arrow2"
	return MonsterAtlasSequence.build_sprite_frames(
		ATLAS_MANIFEST, folder, &"fly", 30.0, true
	)

func _physics_process(delta: float) -> void :
	global_position += _direction * _speed * delta

func _on_arrow_area_entered(area: Area2D) -> void :
	super._on_hit_box_area_entered(area)
	hit_box.set_deferred("monitoring", false)
	queue_timer.start(0.267)

func _on_queue_timer_timeout() -> void :
	queue_free()
