extends Node

const EXPECTED_LEVELS: = {
	69: {"map": "bianfuku", "width": 6000.0, "mobs": [3198, 3199, 3201], "boss": 3200}, 
	70: {"map": "qixingdongV1", "width": 5000.0, "mobs": [3221, 3222, 3226], "boss": 3223}, 
	71: {"map": "wanyaoxueV1", "width": 5000.0, "mobs": [3274, 3275, 3276], "boss": 3277}, 
	72: {"map": "liuligongV3", "width": 5000.0, "mobs": [3308, 3309], "boss": 3310}, 
	73: {"map": "jinyugongV3", "width": 5000.0, "mobs": [3320, 3321, 3322], "boss": 3323}, 
	74: {"map": "futiantai", "width": 5400.0, "mobs": [3340, 3341, 3342], "boss": 3343}, 
	75: {"map": "yunhaiV1", "width": 1200.0, "mobs": [], "boss": 3352}, 
}
const EXPECTED_ALIASES: = {
	3221: 3199, 
	3226: 3198, 
	3274: 3222, 
	3275: 3198, 
	3321: 3308, 
	3322: 3309, 
	3340: 3320, 
	3341: 3308, 
	3342: 3309, 
}
const EXPECTED_FLOOR_SURFACE_Y: = 405.5
const EXPECTED_ROOM_VIEW_WIDTH: = 1200.0
const EXPECTED_FLYING_SPAWN_Y: = 300.0
const EXPECTED_FLYING_MONSTERS: = {
	3198: true, 
	3200: true, 
	3201: true, 
	3226: true, 
	3275: true, 
	3309: true, 
	3322: true, 
	3323: true, 
	3342: true, 
	3343: true, 
	3352: true, 
}
const EXPECTED_OFFICIAL_RANGES: = {
	3198: 65.0, 
	3222: 420.0, 
	3276: 110.0, 
}
const PROGRESSIVE_STAT_KEYS: = ["hp", "attack", "def", "mdef", "armor_break", "magic_break"]

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	var runtime_root: = Node2D.new()
	add_child(runtime_root)
	var old_source_player: Variant = RoleProp.SourcePlayer
	var old_role_position: Variant = RoleProp.role_pos
	RoleProp.SourcePlayer = null
	RoleProp.role_pos = Vector2.ZERO
	var expected_mob_stats: = {
		"hp": 45000000, "attack": 64000, "def": 10500, "mdef": 10500, 
		"armor_break": 14500, "magic_break": 14500, 
	}
	var expected_boss_stats: = {
		"hp": 220000000, "attack": 95000, "def": 12200, "mdef": 12200, 
		"armor_break": 16500, "magic_break": 16500, 
	}

	for effect_key_value: Variant in EastContinentMonster.LATE_SKILL_EFFECTS:
		var effect_key: = str(effect_key_value)
		var key_parts: = effect_key.split(":", false, 1)
		_check(key_parts.size() == 2, "技能特效键格式错误%s" % effect_key)
		if key_parts.size() != 2:
			continue
		var monster_id: = int(key_parts[0])
		var effect_config: Dictionary = EastContinentMonster.LATE_SKILL_EFFECTS[effect_key]
		var manifest_path: = "res://Art/Monster/SwfPng/%d/atlas/manifest.json" % monster_id
		var sequence: = str(effect_config.get("sequence", ""))
		var sequences: Array = effect_config.get("sequences", [sequence]) as Array
		for sequence_value: Variant in sequences:
			var checked_sequence: = str(sequence_value)
			_check(
				_sequence_has_visible_geometry(manifest_path, checked_sequence), 
				"怪物%d技能特效%s没有可见画面" % [monster_id, checked_sequence]
			)
		var impact_sequence: = str(effect_config.get("impact", ""))
		if not impact_sequence.is_empty():
			_check(
				_sequence_has_visible_geometry(manifest_path, impact_sequence), 
				"怪物%d命中特效%s没有可见画面" % [monster_id, impact_sequence]
			)

	for level_number: int in range(69, 76):
		var expected: Dictionary = EXPECTED_LEVELS[level_number]
		for stat_key: String in PROGRESSIVE_STAT_KEYS:
			expected_mob_stats[stat_key] = roundi(float(expected_mob_stats[stat_key]) * 1.1)
			expected_boss_stats[stat_key] = roundi(float(expected_boss_stats[stat_key]) * 1.1)
		var level_path: = "res://Scene/Level/Level_%d.tscn" % level_number
		_check(ResourceLoader.exists(level_path, "PackedScene"), "缺少关卡场景%d" % level_number)
		var level_scene: = load(level_path) as PackedScene
		var level_instance: = level_scene.instantiate()
		_check(int(level_instance.get("stage_number")) == level_number, "关卡%d独立脚本编号错误" % level_number)
		var floor_node: = level_instance.get_node_or_null("wall/floor") as CollisionShape2D
		_check(floor_node != null, "关卡%d缺少地板碰撞" % level_number)
		if floor_node != null and floor_node.shape is RectangleShape2D:
			var floor_shape: = floor_node.shape as RectangleShape2D
			var floor_surface_y: = floor_node.position.y - floor_shape.size.y * 0.5
			_check(is_equal_approx(floor_surface_y, EXPECTED_FLOOR_SURFACE_Y), "关卡%d地面高度错误" % level_number)
		var baked_background_parent: = level_instance.get_node_or_null("BackGround/floor_2")
		_check(baked_background_parent != null, "关卡%d缺少背景父节点" % level_number)
		var baked_background_count: = baked_background_parent.get_child_count() if baked_background_parent != null else 0
		_check(level_instance.get_node_or_null("BackGround/floor_2/bg10_0") != null, "关卡%d背景未烘焙到场景" % level_number)
		var baked_bg10: = level_instance.get_node_or_null("BackGround/floor_2/bg10_0") as Sprite2D
		var baked_bg10_position: = baked_bg10.position if baked_bg10 != null else Vector2.ZERO
		var baked_floor_position: = floor_node.position if floor_node != null else Vector2.ZERO
		var baked_right_wall: = level_instance.get_node_or_null("wall/right_wall") as CollisionShape2D
		var baked_right_wall_position: = baked_right_wall.position if baked_right_wall != null else Vector2.ZERO
		var baked_exit: = level_instance.get_node_or_null("exit") as Node2D
		var baked_exit_position: = baked_exit.position if baked_exit != null else Vector2.ZERO
		(level_instance as Game4EastLateLevel)._build_level_runtime()
		var scrolling_bg: = level_instance.get_node_or_null("BackGround/floor_2/bg10_0") as Sprite2D
		_check(scrolling_bg != null, "关卡%d缺少可滚动地图层" % level_number)
		_check(scrolling_bg == null or scrolling_bg.get_parent().name == &"floor_2", "关卡%d地图层错误固定在屏幕上" % level_number)
		_check(baked_background_parent == null or baked_background_parent.get_child_count() == baked_background_count, "关卡%d运行时重复生成背景" % level_number)
		_check(baked_bg10 == null or baked_bg10.position == baked_bg10_position, "关卡%d运行时覆盖2D背景位置" % level_number)
		_check(floor_node == null or floor_node.position == baked_floor_position, "关卡%d运行时覆盖2D地板位置" % level_number)
		_check(baked_right_wall == null or baked_right_wall.position == baked_right_wall_position, "关卡%d运行时覆盖2D右墙位置" % level_number)
		_check(baked_exit == null or baked_exit.position == baked_exit_position, "关卡%d运行时覆盖2D出口位置" % level_number)
		level_instance.free()
		var map_name: = str(expected["map"])
		var background_root: = "res://Art/Level/Game4Level/Imported/maps/%s/background" % map_name
		_check(ResourceLoader.exists(background_root + "/bg10.png", "Texture2D"), "缺少地图%s主背景" % map_name)

		var level: = level_scene.instantiate() as Game4EastLateLevel
		level._build_birth_points(expected)
		_check(level._level_number() == level_number, "关卡编号错误%d" % level_number)
		var births: = level._birth_points()
		_check( not births.is_empty(), "关卡%d没有出生点" % level_number)
		_check(int(births.back()["monster"]) == int(expected["boss"]), "关卡%d Boss编号错误" % level_number)
		_check(int(births.back()["total"]) == 1, "关卡%d Boss数量错误" % level_number)
		for birth: Dictionary in births:
			var birth_monster_id: = int(birth["monster"])
			var expected_y: = EXPECTED_FLYING_SPAWN_Y if EXPECTED_FLYING_MONSTERS.has(birth_monster_id) else 448.0
			var birth_position: Vector2 = birth["position"]
			_check(is_equal_approx(birth_position.y, expected_y), "怪物%d出生高度错误" % birth_monster_id)
		for mob_id: int in expected["mobs"]:
			_check(_births_contain(births, mob_id), "关卡%d缺少怪物%d" % [level_number, mob_id])
		var screen_starts: = level._screen_starts()
		var screen_rights: = level._screen_rights()
		for screen_index in range(screen_starts.size()):
			var expected_right: = minf(float(screen_starts[screen_index]) + EXPECTED_ROOM_VIEW_WIDTH, float(expected["width"]))
			_check(is_equal_approx(float(screen_rights[screen_index]), expected_right), "关卡%d房间右边界错误" % level_number)

		var ids: Array = expected["mobs"].duplicate()
		ids.append(int(expected["boss"]))
		for monster_id: int in ids:
			var config: = level.get_level_monster_config(monster_id)
			var expected_stats: Dictionary = expected_boss_stats if monster_id == int(expected["boss"]) else expected_mob_stats
			for stat_key: String in PROGRESSIVE_STAT_KEYS:
				_check(int(config.get(stat_key, -1)) == int(expected_stats[stat_key]), "关卡%d怪物%d的%s未按前关1.1倍递增" % [level_number, monster_id, stat_key])
			_check(is_equal_approx(float(config.get("damage_bonus", 0.0)), 0.6), "关卡%d怪物%d增伤不是60%%" % [level_number, monster_id])
			_check(is_equal_approx(float(config.get("damage_reduction", 0.0)), 0.6), "关卡%d怪物%d免伤不是60%%" % [level_number, monster_id])
			_check(bool(config.get("is_flying", false)) == EXPECTED_FLYING_MONSTERS.has(monster_id), "怪物%d飞行类型错误" % monster_id)
			var scene_id: = int(EXPECTED_ALIASES.get(monster_id, monster_id))
			var scene_path: = "res://Scene/Monster/Monster_%d.tscn" % scene_id
			var manifest_path: = "res://Art/Monster/SwfPng/%d/atlas/manifest.json" % scene_id
			_check(ResourceLoader.exists(scene_path, "PackedScene"), "缺少怪物场景%d" % scene_id)
			_check(FileAccess.file_exists(manifest_path), "缺少怪物图集%d" % scene_id)
			_check(Global._canonical_monster_scene_id(monster_id) == scene_id, "怪物%d别名错误" % monster_id)
			var monster_scene: = load(scene_path) as PackedScene
			var monster: = monster_scene.instantiate() as EastContinentMonster
			_check(monster != null, "怪物%d无法实例化" % monster_id)
			if monster == null:
				continue
			monster._runtime_config = config
			monster.position = Vector2(500.0, level._spawn_y(monster_id))
			monster.process_mode = Node.PROCESS_MODE_DISABLED
			runtime_root.add_child(monster)
			await get_tree().process_frame
			if EXPECTED_OFFICIAL_RANGES.has(scene_id):
				_check(
					is_equal_approx(
						monster._effective_attack_range, 
						float(EXPECTED_OFFICIAL_RANGES[scene_id])
					), 
					"怪物%d攻击距离错误，当前%.1f" % [
						scene_id, monster._effective_attack_range
					]
				)
			if scene_id == 3200:
				RoleProp.role_pos = monster.global_position + Vector2(500.0, 0.0)
				var reachable: = monster._reachable_official_attacks()
				_check( not reachable.has(&"hit1"), "怪物3200远距离仍会原地释放近战hit1")
				_check( not reachable.has(&"hit2"), "怪物3200远距离仍会原地释放近战hit2")
				_check(reachable.has(&"hit3"), "怪物3200远距离没有选择可命中的hit3")
			if scene_id == 3198:
				var target_position: = Vector2(540.0, 448.0)
				var scope: Array = EastContinentMonster.OFFICIAL_SKILL_SCOPE[3198][&"hit1"]
				RoleProp.role_pos = target_position
				monster.global_position = Vector2(500.0, EXPECTED_FLYING_SPAWN_Y)
				monster.count = 1
				monster._monster_3119_intelligence()
				_check(monster.velocity.y > 0.0, "吸血蝙蝠不会向人物攻击高度移动")
				monster.global_position = monster._official_scope_stand_position(
					target_position, scope
				)
				monster.velocity = Vector2.ZERO
				monster.count = 30
				_check(
					monster._official_in_skill_scope(target_position, scope), 
					"吸血蝙蝠攻击位置无法覆盖人物"
				)
				monster._monster_3119_intelligence()
				_check(monster.is_attacking and monster.hit_name == "hit1", "吸血蝙蝠不会发动攻击")
			if EastContinentMonster.OFFICIAL_SKILL_SCOPE.has(scene_id):
				var scopes: Dictionary = EastContinentMonster.OFFICIAL_SKILL_SCOPE[scene_id]
				for attack_value: Variant in scopes:
					var attack_name: = attack_value as StringName
					if EastContinentMonster.LATE_SKILL_EFFECTS.has(
						"%d:%s" % [scene_id, str(attack_name)]
					):
						continue
					var scope: Array = scopes[attack_name]
					monster._active_attack_name = attack_name
					monster._sync_attack_collision(true)
					var attack_shape: = monster.hit_box.shape as RectangleShape2D
					var expected_height: = 600.0
					if scope.size() >= 4 and not (
						is_zero_approx(float(scope[2])) and is_zero_approx(float(scope[3]))
					):
						expected_height = float(scope[3]) - float(scope[2])
					_check(
						attack_shape != null and attack_shape.size.is_equal_approx(Vector2(
							float(scope[1]) - float(scope[0]), expected_height
						)), 
						"怪物%d的%s碰撞范围没有使用官方技能矩形" % [
							scene_id, str(attack_name)
						]
					)
			var expected_flying: = EXPECTED_FLYING_MONSTERS.has(monster_id)
			_check(monster.is_Fly == expected_flying, "怪物%d飞行状态没有生效" % monster_id)
			_check(monster.NoGrav == expected_flying, "怪物%d重力状态错误" % monster_id)
			if expected_flying:
				_check(monster.mr_player.has_animation(&"Fly_wait"), "飞行怪%d缺少飞行待机动作" % monster_id)
				_check(monster.mr_player.has_animation(&"Fly"), "飞行怪%d缺少飞行动作" % monster_id)
			_check(monster.mr_ani.sprite_frames.get_frame_count(&"wait") > 0, "怪物%d缺少待机动作" % monster_id)
			_check(monster.mr_ani.sprite_frames.get_frame_count(&"hit1") > 0, "怪物%d缺少攻击动作" % monster_id)
			monster.queue_free()
			await get_tree().process_frame
		level.free()

	RoleProp.SourcePlayer = old_source_player
	RoleProp.role_pos = old_role_position
	runtime_root.queue_free()
	await get_tree().process_frame
	MonsterAtlasSequence.clear_cache()
	Global.clear_level_resource_cache()
	if not _failed:
		print("EAST_LATE_LEVELS_PROBE_OK levels=7 last=75")
	get_tree().quit(1 if _failed else 0)

func _births_contain(births: Array, monster_id: int) -> bool:
	for point: Dictionary in births:
		if int(point["monster"]) == monster_id:
			return true
	return false

func _sequence_has_visible_geometry(manifest_path: String, sequence: String) -> bool:
	var frame_count: = MonsterAtlasSequence.sequence_frame_count(manifest_path, sequence)
	for frame_index in range(frame_count):
		var geometry: = MonsterAtlasSequence.frame_geometry(
			manifest_path, sequence, frame_index
		)
		var size: Vector2 = geometry.get("size", Vector2.ONE)
		if bool(geometry.get("has_visual", false)) and size.x > 1.0 and size.y > 1.0:
			return true
	return false

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_LATE_LEVELS_PROBE_FAIL " + message)
