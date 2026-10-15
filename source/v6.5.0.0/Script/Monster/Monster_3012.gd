extends BaseMonster
class_name WeiyangFlyingAxe

const ROOT: = "res://Art/Monster/SwfPng/3012"
const SOURCE_FPS: = 30.0
const FLY_SPEED: = 50.0
const SCREEN_MARGIN: = 100.0
const ATTACK_INTERVAL: = 0.334
const FLIGHT_VISUAL_OFFSET: = Vector2(3.05, 3.5)
const ATTACK_BODY_SIZE: = Vector2(120.0, 60.0)

static var _frames_cache: SpriteFrames

var removed: = false
var source_boss: Node
var _fly_direction: = 1.0
var _flight_y: = 0.0
var _spawn_position_captured: = false
var _attack_timer: Timer

func _ready() -> void :
	_configure_axe()
	_build_frames()
	super._ready()
	monster_dir.visible = true
	mr_ani.visible = true
	mr_ani.play(&"attack")
	_configure_flying_collision()
	_start_attack_timer()

func _configure_axe() -> void :
	my_mr_name = "旋转斧头"
	level = 90
	attack_in = 18000
	SHp = 1200000
	Hp = SHp
	def = 1200
	mdef = 1200
	crit = 0
	miss = 0
	lucky = 0
	Htarget = 0
	Toughness = 0.0
	Critreduce = 0
	ar = 0
	sp = 0
	speed = FLY_SPEED
	mysee = 2000
	attackRange = 120
	attackDesire = 100
	behit_calmtime = 0.0
	self_rhp = 0
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_stone_pro = 0.0
	fall_list = []
	fall_stone = []
	NoGrav = true
	is_Fly = true
	has_target = true
	CannotAttract = true
	NoTarget = false
	hit_name = "hit1"
	objattackDic = {
		"hit1": {
			"power": int(attack_in * 0.5), 
			"hurtBack": [0, 0], 
			"sourceTargetMove": Vector2(120.0, 60.0), 
			"attackKind": "physics", 
			"HitProtect": 0, 
		}, 
	}

func _build_frames() -> void :
	mr_ani.sprite_frames = _get_frames()
	mr_ani.centered = true
	mr_ani.flip_h = false
	mr_ani.position = FLIGHT_VISUAL_OFFSET

static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames: = SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, &"attack", "DefineSprite_13_attack1", 4, true)
	_frames_cache = frames
	return frames

static func _add_animation(frames: SpriteFrames, animation_name: StringName, directory: String, frame_count: int, looped: bool) -> void :
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, SOURCE_FPS)
	frames.set_animation_loop(animation_name, looped)
	for frame_index in range(1, frame_count + 1):
		var texture: = Global.get_cached_texture(ROOT.path_join(directory).path_join(str(frame_index) + ".png"))
		if texture != null:
			frames.add_frame(animation_name, texture)

func _physics_process(delta: float) -> void :
	if not removed:
		_capture_spawn_position()
		_update_flight_direction()
		_apply_flight_facing()
		velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)
		is_attacking = true
	super._physics_process(delta)
	if not removed:
		position.y = _flight_y
		_apply_flight_facing()
		velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)

func Monster_Intelligence() -> void :
	if removed or death():
		return
	_update_flight_direction()
	_apply_flight_facing()
	velocity = Vector2(FLY_SPEED * _fly_direction, 0.0)

func _capture_spawn_position() -> void :
	if _spawn_position_captured:
		return
	_spawn_position_captured = true
	_flight_y = position.y

func _update_flight_direction() -> void :
	var bounds: = _active_screen_bounds()
	if position.x <= bounds.x + SCREEN_MARGIN:
		_fly_direction = 1.0
	elif position.x >= bounds.y - SCREEN_MARGIN:
		_fly_direction = -1.0

func _apply_flight_facing() -> void :

	MonsterDirection = _fly_direction > 0.0
	mr_ani.flip_h = _fly_direction < 0.0

func _active_screen_bounds() -> Vector2:
	var level_node: = get_level_node()
	if level_node != null and "my_camera" in level_node:
		var camera = level_node.get("my_camera")
		if camera != null and is_instance_valid(camera):
			var left_value = camera.get("max_left")
			var right_value = camera.get("max_right")
			if left_value != null and right_value != null:
				var left: = float(left_value)
				var right: = float(right_value)
				if right - left > SCREEN_MARGIN * 2.0:
					return Vector2(left, right)
	return Vector2(position.x - 600.0, position.x + 600.0)

func _configure_flying_collision() -> void :
	collision_layer = 0
	collision_mask = 0
	if pz != null:
		pz.set_deferred("disabled", true)
	var attack_shape: = RectangleShape2D.new()
	attack_shape.size = ATTACK_BODY_SIZE
	hit_box.shape = attack_shape
	hit_box.position = Vector2.ZERO
	hit_box.set_deferred("disabled", false)
	var receive_shape: = RectangleShape2D.new()
	receive_shape.size = ATTACK_BODY_SIZE
	hurt_box.shape = receive_shape
	hurt_box.position = Vector2.ZERO
	hurt_box.set_deferred("disabled", false)

func _start_attack_timer() -> void :
	_attack_timer = Timer.new()
	_attack_timer.name = "OriginalAttackInterval"
	_attack_timer.wait_time = ATTACK_INTERVAL
	_attack_timer.one_shot = false
	_attack_timer.timeout.connect(_restart_attack_overlap)
	add_child(_attack_timer)
	_attack_timer.start()

func _restart_attack_overlap() -> void :
	if removed or hit_box == null:
		return
	hit_box.set_deferred("disabled", true)
	_reenable_attack_box_after_physics_frame()

func _reenable_attack_box_after_physics_frame() -> void :
	await get_tree().physics_frame
	if is_instance_valid(self) and not removed and hit_box != null:
		hit_box.set_deferred("disabled", false)

func is_control_immune() -> bool:
	return super.is_control_immune()

func state_death() -> void :
	remove_from_battle()

func remove_from_battle() -> void :
	if removed or is_queued_for_deletion():
		return
	removed = true
	is_death = true
	is_attacking = false
	is_be_attacking = false
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	if _attack_timer != null:
		_attack_timer.stop()
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	queue_free()

func monster_info_base_attack() -> int:
	return attack_in

func monster_info_attack_values_include_difficulty() -> bool:
	return false
