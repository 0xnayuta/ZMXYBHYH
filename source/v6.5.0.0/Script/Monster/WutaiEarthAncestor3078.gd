extends BaseMonster
class_name WutaiEarthAncestor3078

const PROJECTILE_SCRIPT: = preload("res://Script/Monster/WutaiMinghaiProjectile.gd")
const ROOT: = "res://Art/Monster/SwfPng/3078"
const ATLAS_MANIFEST: = ROOT + "/atlas/manifest.json"
const SOURCE_FPS: = 24.0
const WALL_ID: = 3082
const WALL_OFFSET_X: = 550.0
const INITIAL_AI_DELAY_MSEC: = 2000
const FULL_HP_CLAW_COOLDOWN_MSEC: = 9000
const HALF_HP_CLAW_COOLDOWN_MSEC: = 6000
const CLAW_SPAWN_DELAY: = 1.0
const CLAW_FRAME_COUNT: = 156
const GROUND_BASELINE_Y: = 138.925

@export var monster_kind: = 3078

var _runtime_config: Dictionary = {}
var _body_stream: StreamedPngEffect
var _effect_streams: Array[StreamedPngEffect] = []
var _walls: Array[BaseMonster] = []
var _busy: = false
var _death_started: = false
var _death_finished: = false
var _walls_spawned: = false
var _attack_serial: = 0
var _next_wall_msec: = 0
var _next_claw_msec: = 0
var _next_decision_msec: = 0
var _locked_claw_position: = Vector2.ZERO

func _ready() -> void :
	NoGrav = true
	IsSuperArmor = true
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_form(_runtime_config)
	_build_animations()
	mr_ani.visible = false
	super._ready()
	_next_wall_msec = Time.get_ticks_msec() + INITIAL_AI_DELAY_MSEC
	_next_claw_msec = 2147483647
	_next_decision_msec = _next_wall_msec
	_enforce_source_direction()

func _resolve_runtime_config() -> Dictionary:
	var level_node: = get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3078 requires level monster config for 3078")
	return {}

func _configure_form(config: Dictionary) -> void :
	my_mr_name = str(config.get("name", "土之祖巫"))
	level = int(config["level"])
	attack_in = int(config["attack"])
	SHp = int(config["hp"])
	Hp = SHp
	def = int(config["def"])
	mdef = int(config["mdef"])
	crit = int(config["crit"])
	miss = int(config["miss"])
	Htarget = int(config["hit"])
	Toughness = float(config["toughness"])
	Critreduce = int(config["crit_reduce"])
	ar = int(config["armor_break"])
	sp = int(config["magic_break"])
	speed = float(config["speed"])
	mysee = int(config["sight"])
	attackRange = int(config["range"])
	attackDesire = int(config["attack_desire"])
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config["drop_rate"])
	fall_list = Array(config["drop_list"]).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	objattackDic.clear()
	var attacks: Dictionary = config.get("attacks", {})
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		objattackDic[attack_name] = {
			"power": roundi(float(attack_in) * float(attack["multiplier"])), 
			"hurtBack": Array(attack["hurt_back"]).duplicate(), 
			"attackKind": str(attack["kind"]), 
			"HitProtect": int(attack["protect"]), 
		}

func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))

func monster_info_attack_values_include_difficulty() -> bool:
	return false

static func prewarm_frames() -> void :
	await MonsterAtlasSequence.prewarm(ATLAS_MANIFEST, 2)

static func prewarm_effects() -> void :
	await MonsterAtlasSequence.prewarm(ATLAS_MANIFEST, 2)

func _build_animations() -> void :
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library: = AnimationLibrary.new()
	library.add_animation(&"wait", _make_animation(41.0 / SOURCE_FPS, true, &"_show_idle"))
	library.add_animation(&"skill1", _make_animation(0.05, false, &"_spawn_stone_walls"))

	var claw_skill: = _make_animation(41.0 / SOURCE_FPS, false, &"_begin_claw_skill")
	_add_method_key(claw_skill, CLAW_SPAWN_DELAY, &"_spawn_locked_claw")
	library.add_animation(&"skill2", claw_skill)

	var death_animation: = _make_animation(50.0 / SOURCE_FPS, false, &"_begin_death_visual")
	_add_method_key(death_animation, death_animation.length - 0.001, &"_finish_final_death")
	library.add_animation(&"death", death_animation)
	mr_player.add_animation_library(&"", library)

func _make_animation(length: float, looped: bool, start_method: StringName) -> Animation:
	var animation: = Animation.new()
	animation.length = maxf(length, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, start_method)
	return animation

func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void :
	var track: = animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, 
		clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), 
		{"method": method_name, "args": args}
	)

func _show_idle() -> void :
	_clear_effect_streams()
	var body_offset: = Vector2(-12.0, -130.575)
	if _body_stream == null or not is_instance_valid(_body_stream):
		_body_stream = _create_stream("idle", 41, body_offset, true, false)
	_body_stream.position = body_offset
	_body_stream.visible = true

func _begin_claw_skill() -> void :
	_clear_body_stream()
	_show_idle()
	_locked_claw_position = global_position
	var role: = Global.get_player as Node2D
	if role != null and is_instance_valid(role):
		_locked_claw_position = Vector2(
			role.global_position.x, 
			global_position.y + GROUND_BASELINE_Y
		)
	elif RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_locked_claw_position = Vector2(
			float(RoleProp.get_nearest_monster_target_position(global_position).x), 
			global_position.y + GROUND_BASELINE_Y
		)

func _spawn_locked_claw() -> void :
	if death():
		return
	var attack_data: = _attack_entry(&"hit2")
	if attack_data.is_empty():
		return
	var claw: = PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	claw.configure({
		"owner": self, 
		"position": _locked_claw_position, 
		"right": true, 
		"hit_name": "hit2", 
		"attack_data": attack_data, 
		"skill_name": "EarthAncestorStoneClaw", 
		"frame_root": ROOT.path_join("claw"), 
		"frame_count": CLAW_FRAME_COUNT, 
		"atlas_manifest": ATLAS_MANIFEST, 
		"atlas_sequence": "claw", 
		"frame_fps": SOURCE_FPS, 
		"loop_visual": false, 
		"visual_offset": Vector2(7.0, -34.5), 
		"lifetime": float(CLAW_FRAME_COUNT) / SOURCE_FPS, 
		"damage_duration": float(CLAW_FRAME_COUNT) / SOURCE_FPS, 
		"max_hits": 1, 
		"expire_on_hit": false, 
		"hit_callback": Callable(self, "_on_claw_hit"), 
	})
	bullet.add_child(claw)

func _on_claw_hit(_projectile: Node, role: BaseHero) -> void :
	if role == null or not is_instance_valid(role) or role.buff == null:
		return
	for buff_name in ["Immobilize", "silent"]:
		Global.AddBuff(role.buff, {
			"Name": buff_name, 
			"AddTime": 5, 
			"ReduceInterval": 0, 
			"value": 0, 
			"AttackKind": "", 
			"CanAdd": false, 
			"DeBuff": true, 
		})

func _spawn_stone_walls() -> void :
	if _walls_spawned or death() or get_parent() == null:
		return
	_walls_spawned = true
	for wall_data in [
		{"offset": - WALL_OFFSET_X, "direction": 1.0}, 
		{"offset": WALL_OFFSET_X, "direction": -1.0}, 
	]:
		var wall: = Global.Create_Monster(
			WALL_ID, 
			get_parent(), 
			position + Vector2(float(wall_data["offset"]), 0.0)
		)
		if not wall is BaseMonster:
			push_error("WutaiEarthAncestor3078 failed to create stone wall 3082")
			continue
		wall.set_meta("is_summon", true)
		if wall.has_method("configure_earth_wall"):
			wall.call("configure_earth_wall", self, float(wall_data["direction"]))
		_walls.append(wall)
	_enforce_source_direction()

func _create_stream(
	folder: String, 
	count: int, 
	offset: Vector2, 
	looped: bool, 
	auto_free: bool
) -> StreamedPngEffect:
	var stream: = StreamedPngEffect.new()
	if not MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, folder):
		return null
	stream.fps = SOURCE_FPS
	stream.loop_animation = looped
	stream.auto_free = auto_free
	stream.position = offset
	monster_dir.add_child(stream)
	return stream

func Monster_Intelligence() -> void :
	velocity = Vector2.ZERO
	if _busy or death() or _runtime_config.is_empty() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	has_target = absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x) <= float(mysee)
	if not has_target:
		return
	var now: = Time.get_ticks_msec()
	if now < _next_decision_msec:
		return
	if not _walls_spawned:
		if now >= _next_wall_msec:
			_start_skill(1)
		return
	if now >= _next_claw_msec:
		_start_skill(2)

func _start_skill(skill_index: int) -> void :
	_attack_serial += 1
	var serial: = _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	if skill_index == 2:
		_next_claw_msec = Time.get_ticks_msec() + _current_claw_cooldown_msec()
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	var now: = Time.get_ticks_msec()
	if skill_index == 1:
		_next_claw_msec = now + randi_range(3000, 6000)
		_next_decision_msec = _next_claw_msec
	elif Hp > SHp * 0.5:
		_next_decision_msec = now + randi_range(3000, 6000)
	else:
		_next_decision_msec = now + randi_range(2000, 4000)
	_busy = false
	is_attacking = false
	mr_player.play(&"wait")

func _current_claw_cooldown_msec() -> int:
	return FULL_HP_CLAW_COOLDOWN_MSEC if Hp > SHp * 0.5 else HALF_HP_CLAW_COOLDOWN_MSEC

func _attack_entry(attack_name: StringName) -> Dictionary:
	var key: = str(attack_name)
	if objattackDic.has(key):
		return (objattackDic[key] as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3078 level config is missing attack %s" % key)
	return {}

func _physics_process(delta: float) -> void :
	super._physics_process(delta)
	_enforce_source_direction()

func _enforce_source_direction() -> void :
	monster_dir.scale.x = -1.0
	base_damage_box.scale.x = 1.0
	velocity = Vector2.ZERO

func is_control_immune() -> bool:
	return true

func state_hurt() -> void :
	pass

func _interrupt_attack_state_on_hit() -> void :
	pass

func _enforce_control_immunity_state() -> void :
	super._enforce_control_immunity_state()
	if _hurt_reaction_active:
		_cancel_hurt_reaction()

func is_alive_for_stage_clear() -> bool:
	return not _death_finished

func state_death() -> void :
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	is_attacking = false
	velocity = Vector2.ZERO
	_clear_walls()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	super.state_death()

func _begin_death_visual() -> void :
	_clear_effect_streams()
	_clear_body_stream()
	_body_stream = _create_stream("death", 50, Vector2(-12.0, -127.575), false, false)

func _finish_final_death() -> void :
	if _death_finished:
		return
	_death_finished = true
	settle_death_drops_and_free()

func _clear_walls() -> void :
	for wall in _walls:
		if wall != null and is_instance_valid(wall):
			wall.queue_free()
	_walls.clear()

func _clear_effect_streams() -> void :
	for stream in _effect_streams:
		if stream != null and is_instance_valid(stream):
			stream.clear_texture()
			stream.queue_free()
	_effect_streams.clear()

func _clear_body_stream() -> void :
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null

func _exit_tree() -> void :
	_clear_walls()
	_clear_effect_streams()
	_clear_body_stream()
