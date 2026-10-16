extends MonsterBullet
class_name Tongtian3057Beam

const ATLAS_MANIFEST := "res://Art/Monster/Tongtian3057/atlas/manifest.json"
const FRAME_COUNT := 28
const SOURCE_FPS := 30.0
const PULSE_COUNT := 4
const PULSE_INTERVAL := 0.1
const PULSE_ACTIVE_TIME := 0.05
const SPRITE_OFFSET := Vector2(712.5, -38.2)

var spawn_global_position := Vector2.ZERO
var facing_right := false
var _visual_stream: StreamedPngEffect

@onready var hit_shape: CollisionShape2D = $middle/HitBox/Hit_Box


func _ready() -> void:
	set_as_top_level(true)
	global_position = spawn_global_position
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.visible = false
	var stream := StreamedPngEffect.new()
	stream.name = "VisualStream"
	MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, "skill_2_overlay")
	stream.fps = SOURCE_FPS
	stream.loop_animation = false
	stream.auto_free = false
	stream.hold_last_frame = true
	stream.position = SPRITE_OFFSET
	middle.add_child(stream)
	_visual_stream = stream
	middle.scale.x = 1.0 if facing_right else -1.0
	hit_box.monitoring = false
	hit_box.monitorable = false
	hit_shape.disabled = true
	queue_timer.start(float(FRAME_COUNT) / SOURCE_FPS)
	_run_hit_pulses()


func _run_hit_pulses() -> void:
	for pulse_index in range(PULSE_COUNT):
		if not is_instance_valid(hit_box) or not is_instance_valid(hit_shape):
			return
		hit_box.monitorable = true
		hit_box.monitoring = true
		hit_shape.set_deferred("disabled", false)
		await get_tree().create_timer(PULSE_ACTIVE_TIME, false).timeout
		if not is_instance_valid(hit_box) or not is_instance_valid(hit_shape):
			return
		hit_box.monitorable = false
		hit_box.monitoring = false
		hit_shape.set_deferred("disabled", true)
		if pulse_index < PULSE_COUNT - 1:
			await get_tree().create_timer(PULSE_INTERVAL - PULSE_ACTIVE_TIME, false).timeout


func _exit_tree() -> void:
	if _visual_stream != null and is_instance_valid(_visual_stream):
		_visual_stream.clear_texture()
