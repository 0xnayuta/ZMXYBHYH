extends MonsterBullet
class_name Tongtian3057Projectile

const ATLAS_MANIFEST := "res://Art/monster/Tongtian3057/atlas/manifest.json"
const FRAME_COUNT := 10
const SOURCE_FPS := 30.0
const SPRITE_OFFSET := Vector2(-21.4, 2.2)
const SOURCE_LIFETIME := 1.267

var spawn_global_position := Vector2.ZERO
var travel_velocity := Vector2.ZERO
var _visual_stream: StreamedPngEffect


func _ready() -> void:
	set_as_top_level(true)
	global_position = spawn_global_position
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.visible = false
	var stream := StreamedPngEffect.new()
	stream.name = "VisualStream"
	MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, "skill_1_projectile")
	stream.fps = SOURCE_FPS
	stream.loop_animation = true
	stream.auto_free = false
	stream.position = SPRITE_OFFSET
	middle.add_child(stream)
	_visual_stream = stream
	middle.scale.x = 1.0 if travel_velocity.x >= 0.0 else -1.0
	queue_timer.start(SOURCE_LIFETIME)


func _physics_process(delta: float) -> void:
	global_position += travel_velocity * delta


func _exit_tree() -> void:
	if _visual_stream != null and is_instance_valid(_visual_stream):
		_visual_stream.clear_texture()
