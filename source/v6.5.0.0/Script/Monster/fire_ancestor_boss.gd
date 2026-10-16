extends BaseMonster
class_name FireAncestorBoss

const PROJECTILE_SCRIPT := preload("res://Script/Monster/nanhai_projectile.gd")
const FIRE_ORB_SCENE := preload("res://Scene/Monster/monster_3056.tscn")
const ROOT := "res://Art/Monster/SwfPng/3042"
const ATLAS_MANIFEST := ROOT + "/atlas/manifest.json"
const SOURCE_FPS := 30.0
const SOURCE_AI_DELAY_MSEC := 2000
const SOURCE_PROJECTILE_SPEED_SCALE := 3.0
const FIRE_ORB_SPAWN_OFFSET := Vector2(450.0, -50.0)

const ACTIONS := {
	&"appear": {"folder": "appear", "frames": 50, "offset": Vector2(11.25, -237.7), "loop": false},
	&"wait": {"folder": "wait", "frames": 50, "offset": Vector2(11.25, -237.7), "loop": true},
	&"effect1": {"folder": "effect1", "frames": 75, "offset": Vector2(3.5, -245.7), "loop": false},
	&"effect2": {"folder": "effect2", "frames": 100, "offset": Vector2(12.75, -357.1), "loop": false},
	&"effect3": {"folder": "effect3", "frames": 94, "offset": Vector2(12.25, -258.7), "loop": false},
	&"death": {"folder": "death", "frames": 50, "offset": Vector2(11.25, -237.7), "loop": false},
}

const EFFECT1_SEGMENTS := [
	{"position": Vector2(-41.0, 75.0), "scale": 1.0, "z": 15},
	{"position": Vector2(-203.0, 44.0), "scale": 0.8, "z": 14},
	{"position": Vector2(138.0, 54.0), "scale": 0.52, "z": 13},
]

const EFFECT3_FLAMES := [
	{"position": Vector2(774.0, -714.0), "frame": 35},
	{"position": Vector2(368.0, -831.0), "frame": 37},
	{"position": Vector2(468.0, -634.0), "frame": 41},
	{"position": Vector2(-123.0, -852.0), "frame": 41},
	{"position": Vector2(-287.0, -895.0), "frame": 41},
	{"position": Vector2(-381.0, -726.0), "frame": 44},
	{"position": Vector2(92.0, -759.0), "frame": 47},
	{"position": Vector2(774.0, -714.0), "frame": 49},
	{"position": Vector2(92.0, -759.0), "frame": 53},
]

var monster_kind := 3042
var _body_stream: StreamedPngEffect
var _runtime_config: Dictionary = {}
var _fixed_global_position := Vector2.ZERO
var _appearance_complete := false
var _busy := true
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _summoned_orbs: Array[FireAncestorOrb] = []


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss()
	_build_animations()
	mr_ani.visible = false
	super._ready()
	_fixed_global_position = global_position
	_enforce_source_state()
	call_deferred("_run_appearance")


func _configure_boss() -> void:
	var config := _runtime_config
	my_mr_name = str(config.get("name", "火之祖巫"))
	level = int(config.get("level", 1))
	attack_in = int(config.get("attack", 1))
	SHp = int(config.get("hp", 1))
	Hp = SHp
	def = int(config.get("def", 0))
	mdef = int(config.get("mdef", 0))
	crit = int(config.get("crit", 0))
	miss = int(config.get("miss", 0))
	Htarget = int(config.get("hit", 0))
	Toughness = float(config.get("toughness", 0.0))
	Critreduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 0))
	sp = int(config.get("magic_break", 0))
	speed = float(config.get("speed", 0.0))
	mysee = int(config.get("sight", 0))
	attackRange = roundi(float(config.get("range", 0.0)))
	attackDesire = int(config.get("attack_desire", 0))
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", true))
	boss_max_protect = float(config.get("max_protect", 100.0))
	NoGrav = true
	is_Fly = true
	IsSuperArmor = true
	CannotAttract = true
	objattackDic.clear()
	var attacks: Dictionary = config.get("attacks", {})
	for skill_index in range(1, 4):
		var attack_name := "hit%d" % skill_index
		var source_name := "effect%d" % skill_index
		var attack_value: Variant = attacks.get(attack_name, attacks.get(source_name, {}))
		if attack_value is Dictionary:
			objattackDic[attack_name] = _attack_data(attack_value as Dictionary)


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("FireAncestorBoss requires level monster config entry 3042")
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
			&"effect1":
				_add_method_key(animation, 0.66, &"_spawn_effect1_segment", [0])
				_add_method_key(animation, 0.726, &"_spawn_effect1_segment", [1])
				_add_method_key(animation, 0.792, &"_spawn_effect1_segment", [2])
			&"effect3":
				for flame_index in range(EFFECT3_FLAMES.size()):
					var source_frame := int(EFFECT3_FLAMES[flame_index]["frame"])
					_add_method_key(
						animation, float(source_frame * 33) / 1000.0, &"_spawn_effect3_flame", [flame_index]
					)
			&"effect2":
				_add_method_key(animation, 0.0, &"_summon_fire_orb")
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


func _play_body_action(action_name: StringName) -> void:
	_enforce_source_state()
	_clear_body_stream()
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	var stream := StreamedPngEffect.new()
	stream.name = "BodyStream"
	if not MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, str(info["folder"])):
		stream.free()
		return
	stream.fps = SOURCE_FPS
	stream.loop_animation = bool(info["loop"])
	stream.auto_free = false
	stream.position = info["offset"]
	stream.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	stream.z_index = -1
	monster_dir.add_child(stream)
	_body_stream = stream


func _run_appearance() -> void:
	mr_player.play(&"appear")
	await mr_player.animation_finished
	if not is_instance_valid(self) or death():
		return
	_appearance_complete = true
	_busy = false
	_next_attack_msec = Time.get_ticks_msec() + SOURCE_AI_DELAY_MSEC
	mr_player.play(&"wait")


func ai_think() -> void:
	_enforce_source_state()
	if (
		not _appearance_complete
		or _busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
	):
		return
	has_target = (
		absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - global_position.x) <= float(mysee)
	)
	var now_msec := Time.get_ticks_msec()
	if not has_target or now_msec < _next_attack_msec:
		return
	_next_attack_msec = now_msec + SOURCE_AI_DELAY_MSEC
	if attackDesire <= 0 or randi_range(1, 100) > attackDesire:
		return
	_skill_cycle = (_skill_cycle % 3) + 1
	_start_skill(_skill_cycle)


func _start_skill(skill_index: int) -> void:
	if _busy or death():
		return
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	is_using_skills = true
	velocity = Vector2.ZERO
	hit_name = "hit%d" % skill_index
	mr_player.play(StringName("effect%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_busy = false
	is_attacking = false
	is_using_skills = false
	_next_attack_msec = Time.get_ticks_msec() + SOURCE_AI_DELAY_MSEC
	mr_player.play(&"wait")


func _spawn_effect1_segment(segment_index: int) -> void:
	if death() or segment_index < 0 or segment_index >= EFFECT1_SEGMENTS.size():
		return
	var segment: Dictionary = EFFECT1_SEGMENTS[segment_index]
	var effect_scale := float(segment["scale"])
	_spawn_streamed_damage_effect(
		{
			"position": global_position + Vector2(segment["position"]),
			"hit_name": "hit1",
			"skill_name": "FireAncestorEffect1_%d" % segment_index,
			"folder": "effect1_1",
			"frame_count": 29,
			"loop_visual": false,
			"visual_scale": Vector2(effect_scale, effect_scale),
			"z_index": int(segment["z"]),
			"collision_size": Vector2(282.0, 254.0) * effect_scale,
			"collision_offset": Vector2.ZERO,
			"lifetime": 29.0 / SOURCE_FPS,
			"damage_duration": 29.0 / SOURCE_FPS,
		}
	)


func _summon_fire_orb() -> void:
	if death():
		return
	var parent := get_parent() as Node2D
	if parent == null:
		return
	var orb := FIRE_ORB_SCENE.instantiate() as FireAncestorOrb
	if orb == null:
		return
	orb.position = parent.to_local(global_position + FIRE_ORB_SPAWN_OFFSET)
	parent.add_child(orb)
	orb.tree_exited.connect(_forget_summoned_orb.bind(orb), CONNECT_ONE_SHOT)
	_summoned_orbs.append(orb)


func _forget_summoned_orb(orb: FireAncestorOrb) -> void:
	_summoned_orbs.erase(orb)


func _clear_summoned_orbs() -> void:
	for orb in _summoned_orbs:
		if orb != null and is_instance_valid(orb):
			orb.queue_free()
	_summoned_orbs.clear()


func _spawn_effect3_flame(flame_index: int) -> void:
	if death() or flame_index < 0 or flame_index >= EFFECT3_FLAMES.size():
		return
	var flame: Dictionary = EFFECT3_FLAMES[flame_index]
	_spawn_streamed_damage_effect(
		{
			"position": global_position + Vector2(flame["position"]),
			"hit_name": "hit3",
			"skill_name": "FireAncestorFallingFlame_%d" % flame_index,
			"folder": "effect3_1",
			"frame_count": 16,
			"loop_visual": true,
			"visual_scale": Vector2.ONE,
			"z_index": 12,
			"collision_size": Vector2(125.0, 112.0),
			"collision_offset": Vector2.ZERO,
			"velocity": Vector2(-40.0, randf_range(100.0, 150.0)) * SOURCE_PROJECTILE_SPEED_SCALE,
			"orient_to_motion": true,
			"lifetime": 3.0,
			"damage_duration": 3.0,
		}
	)


func _spawn_streamed_damage_effect(config: Dictionary) -> void:
	var effect_hit_name := str(config["hit_name"])
	var attack_value: Variant = objattackDic.get(effect_hit_name, {})
	var has_attack_data := attack_value is Dictionary and not (attack_value as Dictionary).is_empty()
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	(
		projectile
		. configure(
			{
				"owner": self,
				"position": config["position"],
				"right": true,
				"hit_name": effect_hit_name,
				"attack_data": (attack_value as Dictionary) if has_attack_data else {},
				"skill_name": str(config["skill_name"]),
				"frame_root": "",
				"frame_count": 0,
				"loop_visual": false,
				"velocity": config.get("velocity", Vector2.ZERO),
				"orient_to_motion": bool(config.get("orient_to_motion", false)),
				"collision_size": config["collision_size"],
				"collision_offset": config.get("collision_offset", Vector2.ZERO),
				"lifetime": float(config["lifetime"]),
				"damage_duration": float(config["damage_duration"]),
				"damage_enabled": has_attack_data,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	var built_in_visual := projectile.get_node("middle/BulletANI") as AnimatedSprite2D
	built_in_visual.visible = false
	var stream := StreamedPngEffect.new()
	stream.name = "StreamedVisual"
	if not MonsterAtlasSequence.configure_stream(stream, ATLAS_MANIFEST, str(config["folder"])):
		stream.free()
		projectile.queue_free()
		return
	stream.fps = SOURCE_FPS
	stream.loop_animation = bool(config["loop_visual"])
	stream.auto_free = not stream.loop_animation
	stream.scale = config.get("visual_scale", Vector2.ONE)
	stream.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	stream.z_index = int(config.get("z_index", 0))
	projectile.get_node("middle").add_child(stream)
	bullet.add_child(projectile)


func _physics_process(delta: float) -> void:
	_enforce_source_state()
	super._physics_process(delta)
	velocity = Vector2.ZERO
	global_position = _fixed_global_position
	NoGrav = true
	is_Fly = true
	IsSuperArmor = true
	CannotAttract = true
	_enforce_source_state()


func _enforce_source_state() -> void:
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0
	mr_ani.flip_h = false
	MonsterDirection = false
	velocity = Vector2.ZERO


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
	_clear_summoned_orbs()
	_attack_serial += 1
	_cancel_hurt_reaction()
	_busy = true
	is_attacking = false
	is_using_skills = false
	velocity = Vector2.ZERO
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	mr_player.speed_scale = 1.0
	super.state_death()


func _clear_body_stream() -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null


func _exit_tree() -> void:
	_clear_summoned_orbs()
	_clear_body_stream()
