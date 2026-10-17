extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const ROOT := "res://Art/monster/SwfPng/3035"
const ATLAS_MANIFEST := ROOT + "/atlas/manifest.json"
const SOURCE_FPS := 30.0
const PRIMARY_SKILL_COOLDOWN_MSEC := 9000
const WHIRLPOOL_COOLDOWN_MSEC := 18000
const PRIMARY_WAIT_MSEC := Vector2i(3000, 6000)
const WHIRLPOOL_INTERVAL := 1.5
const WHIRLPOOL_POST_WAIT_MSEC := Vector2i(1000, 2000)
const WHIRLPOOL_CAST_COUNT := 3
const WHIRLPOOL_COLUMN_VISUAL_OFFSET := Vector2(0.8, -200.0)
const WHIRLPOOL_WARNING_VISUAL_OFFSET := Vector2(-2.35, 102.1)

const ACTIONS := {
	&"appear": {"folder": "appear", "frames": 50, "offset": Vector2(-2.4, -255.75), "loop": false},
	&"wait": {"folder": "wait", "frames": 36, "offset": Vector2(-10.65, -254.75), "loop": true},
	&"death": {"folder": "death", "frames": 50, "offset": Vector2(-2.4, -255.75), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 62, "offset": Vector2(-87.0, -396.9), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 95, "offset": Vector2(9.3, -238.45), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 42, "offset": Vector2(-0.6, -266.65), "loop": false},
}

var monster_kind := 3035
var _body_stream: StreamedPngEffect
var _busy := true
var _death_started := false
var _appearance_complete := false
var _attack_serial := 0
var _skill_cycle := 0
var _wait_until_msec := 0
var _skill_ready_msec := {1: 0, 2: 0, 3: 0}
var _runtime_config: Dictionary = {}


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss()
	_build_animations()
	mr_ani.visible = false
	super._ready()
	_enforce_source_direction()
	call_deferred("_run_appearance")


func _configure_boss() -> void:
	var config := _runtime_config
	my_mr_name = str(config.get("name", "水之祖巫"))
	level = int(config.get("level", 1))
	attack_in = int(config.get("attack", 1))
	SHp = int(config.get("hp", 1))
	Hp = SHp
	def = int(config.get("def", 0))
	mdef = int(config.get("mdef", 0))
	crit = int(config.get("crit", 0))
	miss = int(config.get("miss", 0))
	htarget = int(config.get("hit", 0))
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 0))
	sp = int(config.get("magic_break", 0))
	speed = float(config.get("speed", 0.0))
	mysee = int(config.get("sight", 0))
	attack_range = roundi(float(config.get("range", 0.0)))
	attack_desire = int(config.get("attack_desire", 0))
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", true))
	boss_max_protect = float(config.get("max_protect", 100.0))
	no_grav = true
	is_fly = true
	super_armor_active = true
	cannot_attract = true
	obj_attack_dict.clear()
	var attacks: Dictionary = config.get("attacks", {})
	for attack_name: String in attacks:
		obj_attack_dict[attack_name] = _attack_data(attacks[attack_name])


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WaterAncestorBoss requires Level_55 LEVEL_55_MONSTER_DATA entry 3035")
	return {}


func _attack_data(attack: Dictionary) -> Dictionary:
	return {
		"power": roundi(float(attack_in) * float(attack.get("multiplier", 0.0))),
		"hurtBack": Array(attack.get("hurt_back", [0, 0])).duplicate(),
		"attackKind": str(attack.get("kind", "physics")),
		"HitProtect": int(attack.get("protect", 0)),
	}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


func is_control_immune() -> bool:
	return true


static func prewarm_frames() -> void:
	await MonsterAtlasSequence.prewarm(ATLAS_MANIFEST, 2)


static func prewarm_effects() -> void:
	await MonsterAtlasSequence.prewarm(ATLAS_MANIFEST, 2)


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := _make_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill1":
				_add_method_key(animation, 0.0, &"_spawn_spear_sweep")
			&"skill2":
				for shot_index in range(3):
					_add_method_key(animation, 0.825 + float(shot_index) * 0.495, &"_spawn_water_shot")
			&"skill3":
				_add_method_key(animation, 0.561, &"_spawn_whirlpool_warning")
				_add_method_key(animation, 0.825, &"_spawn_whirlpool_column")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _play_body_action(action_name: StringName) -> void:
	_enforce_source_direction()
	_clear_body_stream()
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	var stream := StreamedPngEffect.new()
	stream.name = "BodyStream"
	if not MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, str(info["folder"])):
		stream.free()
		return
	stream.fps = SOURCE_FPS
	stream.loop_animation = bool(info.get("stream_loop", info["loop"]))
	stream.auto_free = false
	stream.position = info["offset"]
	stream.z_index = -1
	monster_dir.add_child(stream)
	_body_stream = stream


func _run_appearance() -> void:
	mr_player.play(&"appear")
	await mr_player.animation_finished
	if death():
		return
	_busy = false
	_appearance_complete = true
	var now_msec := Time.get_ticks_msec()
	_skill_ready_msec[1] = now_msec + PRIMARY_SKILL_COOLDOWN_MSEC
	_skill_ready_msec[2] = now_msec + PRIMARY_SKILL_COOLDOWN_MSEC
	_skill_ready_msec[3] = now_msec + WHIRLPOOL_COOLDOWN_MSEC
	mr_player.play(&"wait")


func ai_think() -> void:
	_enforce_source_direction()
	if (
		not _appearance_complete
		or _busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
	):
		return
	has_target = (
		absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x) <= float(mysee)
	)
	var now_msec := Time.get_ticks_msec()
	if not has_target or now_msec < _wait_until_msec:
		return
	if now_msec >= int(_skill_ready_msec[3]):
		_start_whirlpool_sequence()
		return
	for step in range(2):
		var skill_index := ((_skill_cycle + step) % 2) + 1
		if now_msec >= int(_skill_ready_msec[skill_index]):
			_start_skill(skill_index)
			return


func _start_skill(skill_index: int) -> void:
	_enforce_source_direction()
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 2
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	hit_name = "hit%d" % skill_index
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_busy = false
	is_attacking = false
	_skill_ready_msec[skill_index] = Time.get_ticks_msec() + PRIMARY_SKILL_COOLDOWN_MSEC
	_wait_until_msec = Time.get_ticks_msec() + randi_range(PRIMARY_WAIT_MSEC.x, PRIMARY_WAIT_MSEC.y)
	mr_player.play(&"wait")


func _start_whirlpool_sequence() -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	for cast_index in range(WHIRLPOOL_CAST_COUNT):
		hit_name = "hit3"
		mr_player.play(&"skill3")
		await mr_player.animation_finished
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
		if cast_index + 1 < WHIRLPOOL_CAST_COUNT:
			mr_player.play(&"wait")
			await get_tree().create_timer(WHIRLPOOL_INTERVAL, false).timeout
			if not is_instance_valid(self) or death() or serial != _attack_serial:
				return
	_busy = false
	is_attacking = false
	_skill_ready_msec[3] = Time.get_ticks_msec() + WHIRLPOOL_COOLDOWN_MSEC
	_wait_until_msec = Time.get_ticks_msec() + randi_range(WHIRLPOOL_POST_WAIT_MSEC.x, WHIRLPOOL_POST_WAIT_MSEC.y)
	mr_player.play(&"wait")


func _spawn_spear_sweep() -> void:
	_spawn_projectile(
		{
			"position": global_position,
			"right": true,
			"hit_name": "hit1",
			"attack_data": obj_attack_dict["hit1"],
			"skill_name": "WaterAncestorSpearSweep",
			"atlas_sequence": "effect1_1",
			"frame_count": 48,
			"visual_offset": Vector2.ZERO,
			"loop_visual": false,
			"collision_size": Vector2(754.9, 816.3),
			"collision_offset": Vector2(-102.75, -470.85),
			"hit_delay": 34.0 / SOURCE_FPS,
			"lifetime": 62.0 / SOURCE_FPS,
			"damage_duration": 15.0 / SOURCE_FPS,
			"expire_on_hit": false,
		}
	)


func _spawn_water_shot() -> void:
	if death():
		return
	var aim_origin := global_position + Vector2(-135.0, -410.0)
	var spawn_position := aim_origin
	var target_position := aim_origin + Vector2(-400.0, 0.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	if RoleProp.get_nearest_monster_target_position(global_position).y != null:
		target_position.y = float(RoleProp.get_nearest_monster_target_position(global_position).y)
	var direction := (target_position - aim_origin).normalized()
	_spawn_projectile(
		{
			"position": spawn_position,
			"right": true,
			"hit_name": "hit2",
			"attack_data": obj_attack_dict["hit2"],
			"skill_name": "WaterAncestorChainShot",
			"atlas_sequence": "effect2_1",
			"frame_count": 12,
			"visual_offset": Vector2(34.5, 3.8),
			"velocity": direction * 120.0,
			"orient_to_motion": true,
			"collision_size": Vector2(144.05, 52.05),
			"collision_offset": Vector2(45.975, -0.025),
			"lifetime": 5.0,
			"damage_duration": 5.0,
		}
	)


func _spawn_whirlpool_warning() -> void:
	_spawn_whirlpool(false)


func _spawn_whirlpool_column() -> void:
	_spawn_whirlpool(true)


func _spawn_whirlpool(damaging: bool) -> void:
	if death():
		return
	var target_position := global_position
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_position.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	_spawn_projectile(
		{
			"position": target_position,
			"right": true,
			"hit_name": "hit3",
			"attack_data": obj_attack_dict["hit3"],
			"skill_name": "WaterAncestorWhirlpool",
			"atlas_sequence": "effect3_1" if damaging else "effect3_2",
			"frame_count": 22 if damaging else 15,
			"visual_offset": WHIRLPOOL_COLUMN_VISUAL_OFFSET if damaging else WHIRLPOOL_WARNING_VISUAL_OFFSET,
			"collision_size": Vector2(121.05, 661.2),
			"collision_offset": Vector2(-4.025, -306.1),
			"lifetime": 0.734 if damaging else 0.5,
			"damage_duration": 0.734 if damaging else 0.0,
			"damage_enabled": damaging,
			"expire_on_hit": false,
		}
	)


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	var atlas_sequence := str(config.get("atlas_sequence", ""))
	var loop_visual := bool(config.get("loop_visual", true))
	config["frame_root"] = ""
	config["frame_count"] = 0
	config["owner"] = self
	projectile.configure(config)
	var visual := projectile.get_node("middle/BulletANI") as AnimatedSprite2D
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	bullet.add_child(projectile)
	visual.visible = false
	var stream := StreamedPngEffect.new()
	stream.name = "StreamedVisual"
	if not MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, atlas_sequence):
		stream.free()
		projectile.queue_free()
		return null
	stream.fps = SOURCE_FPS
	stream.loop_animation = loop_visual
	stream.auto_free = false
	stream.hold_last_frame = not loop_visual
	stream.flip_h = visual.flip_h
	var stream_offset: Variant = config.get("visual_offset", Vector2.ZERO)
	var resolved_stream_offset := stream_offset as Vector2 if stream_offset is Vector2 else Vector2.ZERO
	if stream.flip_h:
		resolved_stream_offset.x = -resolved_stream_offset.x
	stream.position = visual.position + resolved_stream_offset
	stream.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	projectile.get_node("middle").add_child(stream)
	return projectile


func _physics_process(delta: float) -> void:
	_enforce_source_direction()
	super._physics_process(delta)
	velocity = Vector2.ZERO
	no_grav = true
	is_fly = true
	super_armor_active = true
	cannot_attract = true
	_enforce_source_direction()


func _enforce_source_direction() -> void:
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0
	monster_direction = false


func state_hurt() -> void:
	pass


func _interrupt_attack_state_on_hit() -> void:
	pass


func _enforce_control_immunity_state() -> void:
	super._enforce_control_immunity_state()
	if _hurt_reaction_active:
		_cancel_hurt_reaction()


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_cancel_hurt_reaction()
	_busy = true
	is_attacking = false
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	velocity = Vector2.ZERO
	no_grav = true
	mr_player.speed_scale = 1.0
	mr_player.play(&"death")


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, -510.0)


func _clear_body_stream() -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null


func _exit_tree() -> void:
	_clear_body_stream()
