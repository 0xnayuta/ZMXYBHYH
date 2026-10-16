extends MonsterBullet

const FRAME_ROOT := "res://Art/Monster/SwfPng/3004"
const FLY_FRAME_COUNT := 4
const EXPLODE_FRAME_COUNT := 14
const SOURCE_FPS := 30.0
const ATLAS_MANIFEST := FRAME_ROOT + "/atlas/manifest.json"

static var _frames_cache: SpriteFrames
var _move_speed := 620.0
var _target_x := 0.0
var _is_exploding := false


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.play(&"fly")

	middle.scale.x = 1 if dir else -1
	_target_x = global_position.x + (520.0 if dir else -520.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var travel_distance := absf(_target_x - global_position.x)
	_move_speed = clampf(travel_distance / 0.7, 320.0, 900.0)
	hit_box.area_entered.connect(_on_fireball_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(2.5)


func _physics_process(delta: float) -> void:
	if _is_exploding:
		return
	var direction_sign := 1.0 if dir else -1.0
	global_position.x += direction_sign * _move_speed * delta
	if (dir and global_position.x >= _target_x) or (not dir and global_position.x <= _target_x):
		_explode()


func _on_fireball_area_entered(area: Area2D) -> void:
	if _is_exploding:
		return
	super._on_hit_box_area_entered(area)
	_explode()


func _explode() -> void:
	if _is_exploding:
		return
	_is_exploding = true
	queue_timer.stop()
	var collision := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)
	bullet_ani.play(&"explode")
	await get_tree().physics_frame
	if collision != null and is_instance_valid(collision):
		var explosion_shape := RectangleShape2D.new()
		explosion_shape.size = Vector2(175, 135)
		collision.shape = explosion_shape
		collision.set_deferred("disabled", false)
	await bullet_ani.animation_finished
	queue_free()


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	if ResourceLoader.exists(ATLAS_MANIFEST):
		MonsterAtlasSequence.add_animation(frames, ATLAS_MANIFEST, "arrow1", &"fly", SOURCE_FPS, true)
		MonsterAtlasSequence.add_animation(frames, ATLAS_MANIFEST, "arrow2", &"explode", SOURCE_FPS, false)
		_frames_cache = frames
		return frames
	frames.add_animation(&"fly")
	frames.set_animation_loop(&"fly", true)
	frames.set_animation_speed(&"fly", SOURCE_FPS)
	for index in range(1, FLY_FRAME_COUNT + 1):
		var texture := Global.get_cached_texture(FRAME_ROOT.path_join("arrow1").path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"fly", texture)
	frames.add_animation(&"explode")
	frames.set_animation_loop(&"explode", false)
	frames.set_animation_speed(&"explode", SOURCE_FPS)
	for index in range(1, EXPLODE_FRAME_COUNT + 1):
		var texture := Global.get_cached_texture(FRAME_ROOT.path_join("arrow2").path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"explode", texture)
	_frames_cache = frames
	return frames
