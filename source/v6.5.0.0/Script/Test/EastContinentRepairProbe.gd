extends Node

const ALIASES: Dictionary = {3126: 3119, 3145: 3121, 3146: 3122, 3178: 3159, 3183: 3177}
var _failed: bool = false
var _levels: Array[Game4ImportedLevel] = []

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	print("USER_DIR ", OS.get_user_data_dir())
	var global: Node = get_tree().root.get_node("Global")
	var main_set: Node = get_tree().root.get_node("MainSet")
	main_set.set_data["Difficult"] = 0
	main_set.set_data["MonsterBloodSHow"] = false
	main_set.set_data["MonsterLittleBlood"] = false
	for number: int in range(63, 69):
		var script: GDScript = load("res://Script/Level/Level_%d.gd" % number)
		var level: Game4ImportedLevel = script.new() as Game4ImportedLevel
		_levels.append(level)
	var total: int = 0
	for level: Game4ImportedLevel in _levels:
		for point: Dictionary in level._birth_points():
			total += int(point["total"])
	_check(total == 310, "Base spawn total changed")
	var original_count_multiplier: int = int(main_set.set_data.get("CreateMonsterCount", 1))
	var aolaiguo_level: Game4ImportedLevel = _levels[2]
	main_set.set_data["CreateMonsterCount"] = 4
	aolaiguo_level._configure_level_monsters()
	aolaiguo_level._apply_monster_count_multiplier()
	_check(aolaiguo_level.Monster_group["stage_1"].size() == 48, "Regular monsters lost count multiplier")
	_check(aolaiguo_level.Monster_group["stage_5"].size() == 1, "Aolaiguo boss was duplicated")
	_check(int(aolaiguo_level._point_states[50]["target"]) == 1, "Aolaiguo boss point target was multiplied")
	main_set.set_data["CreateMonsterCount"] = original_count_multiplier
	_check( not _levels[5]._allows_deep_monster_positions(), "Level68 should use the fixed boss room")
	var mushroom_total: int = 0
	for point: Dictionary in _levels[5]._birth_points():
		if int(point["monster"]) == 3183:
			mushroom_total += int(point["total"])
	_check(mushroom_total == 8, "Expected 8 mushroom elders across three waves")
	var runtime_root: Node2D = Node2D.new()
	add_child(runtime_root)
	for source_id: int in ALIASES:
		var scene_id: int = int(ALIASES[source_id])
		_check(global._canonical_monster_scene_id(source_id) == scene_id, "Scene alias %d" % source_id)
		_check(MonsterAtlasSequence.manifest_for_model(source_id) == MonsterAtlasSequence.manifest_for_model(scene_id), "Atlas alias %d" % source_id)
		var level_index: int = 1 if source_id == 3126 else (2 if source_id in [3145, 3146] else (4 if source_id == 3178 else 5))
		var monster: EastContinentMonster = global.Create_Monster(source_id, runtime_root, Vector2(500, 1000)) as EastContinentMonster
		_check(monster != null, "Instantiate alias %d" % source_id)
		if monster == null:
			continue
		monster.BaseLevel_ = _levels[level_index]
		monster.level_cache_valid = true
		monster.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().process_frame
		_check(monster.monster_kind == scene_id, "Visual kind %d" % source_id)
		_check(int(monster.get_meta("source_monster_id", 0)) == source_id, "Source identity %d" % source_id)
		_check(monster.mr_ani.sprite_frames.get_frame_count(&"hit1") > 0, "Missing hit animation %d" % source_id)
		if source_id == 3126:
			_check(monster.is_Fly and monster.NoGrav, "Bee is not flying")
			_check(monster.my_mr_name == "煞人蜂", "Bee name")
		if source_id == 3178:
			_check(int(monster._config["hp"]) == 21500000, "Water cave monkey HP changed")
			_check(is_equal_approx(monster.damage_reduction, 0.6), "Water cave balance changed")
		if source_id == 3183:
			_check(monster.my_mr_name == "蘑菇长老", "Mushroom name")
			_check(monster.mr_player.has_animation(&"hit2"), "Missing ranged attack")
		monster.queue_free()
		await get_tree().process_frame
	var peach_level: Game4ImportedLevel = _levels[5]
	_check(peach_level._stage_count() == 4, "Level68 should contain three waves and one boss wave")
	_check(peach_level._screen_starts() == [0.0, 0.0, 0.0, 0.0], "Level68 still changes rooms")
	_check(peach_level._screen_rights() == [1200.0, 1200.0, 1200.0, 1200.0], "Level68 room bounds changed")
	var boss_point: Dictionary = peach_level._birth_points().back()
	_check(int(boss_point["stage"]) == 4 and int(boss_point["monster"]) == 3182, "Level68 boss wave changed")
	_check((boss_point["position"] as Vector2).is_equal_approx(Vector2(900, 563)), "Level68 boss spawn no longer matches the floor")
	runtime_root.queue_free()
	var rain_boss: EastContinentMonster = global.Create_Monster(3182, self, Vector2(900, 448)) as EastContinentMonster
	_check(rain_boss != null, "Rain ancestor boss scene missing")
	if rain_boss != null:
		rain_boss.BaseLevel_ = peach_level
		rain_boss.level_cache_valid = true
		rain_boss.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		rain_boss.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().process_frame
		_check(rain_boss.NoGrav, "Rain ancestor boss must ignore gravity")
		_check(rain_boss.is_control_immune(), "Rain ancestor boss must be control immune")
		for action: StringName in [&"hit1", &"hit2", &"hit3", &"hit4", &"hit5"]:
			_check(rain_boss.mr_player.has_animation(action), "Rain ancestor missing %s" % action)
			_check(rain_boss.mr_ani.sprite_frames.get_frame_count(action) > 0, "Rain ancestor empty %s" % action)
		var rain_manifest: = rain_boss._manifest_path()
		_check(MonsterAtlasSequence.sequence_frame_count(rain_manifest, "effect2_1") == 1, "Rain ancestor tracking needle missing")
		_check(MonsterAtlasSequence.sequence_frame_count(rain_manifest, "effect3_1") == 12, "Rain ancestor bone needle missing")
		_check(int(rain_boss.objattackDic["hit2"]["power"]) == roundi(float(rain_boss.attack_in) * 0.75), "Rain ancestor rain needle damage changed")
		_check(Array(rain_boss.objattackDic["hit3"]["sourceTargetMove"]) == [33, 66], "Rain ancestor bone needle knockback changed")
		rain_boss.Hp = roundi(float(rain_boss.SHp) * 0.5)
		_check(rain_boss._pick_3182_attack() == &"hit5", "Rain ancestor low-health rain combo did not trigger")
		rain_boss.is_stun = true
		rain_boss.is_ice = true
		rain_boss.is_Immobilize = true
		rain_boss._enforce_control_immunity_state()
		_check( not rain_boss.is_stun and not rain_boss.is_ice and not rain_boss.is_Immobilize, "Rain ancestor boss retained control state")
		var rain_fixed_position: = rain_boss.global_position
		rain_boss.global_position += Vector2(-180, 90)
		rain_boss.velocity = Vector2(-420, 260)
		rain_boss._physics_process(1.0 / 60.0)
		_check(rain_boss.global_position.is_equal_approx(rain_fixed_position), "Rain ancestor boss moved from spawn point")
		_check(rain_boss.velocity == Vector2.ZERO, "Rain ancestor boss retained movement velocity")
		rain_boss.queue_free()
		await get_tree().process_frame
	var thunder_boss: EastContinentMonster = global.Create_Monster(3277, self, Vector2(4480, 448)) as EastContinentMonster
	_check(thunder_boss != null, "Thunder ancestor boss scene missing")
	if thunder_boss != null:
		thunder_boss.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		thunder_boss.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().process_frame
		_check(thunder_boss.is_control_immune(), "Thunder ancestor boss must be control immune")
		thunder_boss.is_stun = true
		thunder_boss.is_ice = true
		thunder_boss.is_Immobilize = true
		thunder_boss._enforce_control_immunity_state()
		_check( not thunder_boss.is_stun and not thunder_boss.is_ice and not thunder_boss.is_Immobilize, "Thunder ancestor boss retained control state")
		var thunder_hurt_texture: = thunder_boss.mr_ani.sprite_frames.get_frame_texture(&"hurt", 0)
		_check(thunder_hurt_texture != null and thunder_hurt_texture.get_width() > 1 and thunder_hurt_texture.get_height() > 1, "Thunder ancestor hurt animation still contains a blank frame")
		thunder_boss.queue_free()
		await get_tree().process_frame
	var aolaiguo_boss: EastContinentMonster = global.Create_Monster(3136, self, Vector2(4487, 448)) as EastContinentMonster
	_check(aolaiguo_boss != null, "Aolaiguo boss scene missing")
	if aolaiguo_boss != null:
		aolaiguo_boss.BaseLevel_ = _levels[2]
		aolaiguo_boss.level_cache_valid = true
		aolaiguo_boss.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
		aolaiguo_boss.process_mode = Node.PROCESS_MODE_DISABLED
		await get_tree().process_frame
		_check(aolaiguo_boss.is_boss, "Aolaiguo boss flag missing")
		_check(aolaiguo_boss.NoGrav, "Aolaiguo boss must stay on mural")
		_check(aolaiguo_boss.is_control_immune(), "Aolaiguo boss must be control immune")
		aolaiguo_boss.is_stun = true
		aolaiguo_boss.is_ice = true
		aolaiguo_boss.is_Immobilize = true
		aolaiguo_boss._enforce_control_immunity_state()
		_check( not aolaiguo_boss.is_stun and not aolaiguo_boss.is_ice and not aolaiguo_boss.is_Immobilize, "Aolaiguo boss retained control state")
		var fixed_position: = aolaiguo_boss.global_position
		aolaiguo_boss.global_position += Vector2(120, -80)
		aolaiguo_boss.velocity = Vector2(300, -200)
		aolaiguo_boss._physics_process(1.0 / 60.0)
		_check(aolaiguo_boss.global_position.is_equal_approx(fixed_position), "Aolaiguo boss moved from spawn point")
		_check(aolaiguo_boss.velocity == Vector2.ZERO, "Aolaiguo boss retained movement velocity")
		_check(aolaiguo_boss.mr_ani.sprite_frames.get_frame_count(&"hit1") == 30, "Aolaiguo boss attack animation missing")
		_check(MonsterAtlasSequence.sequence_frame_count(aolaiguo_boss._manifest_path(), "effect1_1") == 15, "Aolaiguo boss effect missing")
		aolaiguo_boss.queue_free()
		await get_tree().process_frame
	for level: Game4ImportedLevel in _levels:
		level.queue_free()
	_levels.clear()
	await get_tree().process_frame
	MonsterAtlasSequence.clear_cache()
	global.clear_level_resource_cache()
	if not _failed:
		print("EAST_REPAIR_PROBE_OK aliases=5 births=310 bosses=3136,3182,3277 mushrooms=8 level68=fixed_room")
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_REPAIR_PROBE_FAIL " + message)
