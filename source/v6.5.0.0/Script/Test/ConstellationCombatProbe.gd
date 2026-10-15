extends SceneTree

const MonsterAtlasSequence = preload("res://Script/Monster/MonsterAtlasSequence.gd")
const LEVEL_SCRIPT_PATH: = "res://Script/Level/Level_esbxx.gd"
const LEVEL_INFO_SCRIPT_PATH: = "res://Scene/OtherScene/LevelInfo.gd"
const MONSTER_HEAD_SCENE_PATH: = "res://Scene/OtherScene/MonsterHeadInfo.tscn"
const PROJECTILE_SCRIPT_PATH: = "res://Script/Monster/WutaiMinghaiProjectile.gd"
const BASE_MONSTER_SCENE_PATH: = "res://Scene/Base/BaseMonster.tscn"
const BASE_HERO_SCENE_PATH: = "res://Scene/Base/BaseHero.tscn"
const BOSS_BLOOD_SCENE_PATH: = "res://Scene/MonsterBlood/BossBlood.tscn"
const EXPECTED_BOSS_NAMES: = [
	"轸宿", "翼火蛇", "张月鹿", "星日马", "柳宿", "鬼宿", "井宿", 
	"壁宿", "室宿", "危宿", "虚宿", "女宿", "牛宿", "斗宿", 
]
const EXPECTED_SKILL_BOOK_DROPS: = [
	"smjc_skill_book", "gjjc_skill_book", "fyjc_skill_book", "mfby_skill_book", "sxkb_skill_book", 
	"fsnl_skill_book", "tsml_skill_book", "zrsh_skill_book", "smzf_skill_book", "mfjc_skill_book", 
]

var _hit_callbacks: = 0
var _reverse_area_events: = 0


func _init() -> void :
	call_deferred("_run")


func _run() -> void :
	if not await _verify_tier_names():
		return
	if not _verify_hover_attributes():
		return
	if not await _verify_frame_collision_alignment():
		return
	if not await _verify_empty_visual_frames():
		return
	if not await _verify_projectile_damage_window():
		return
	print(
		"CONSTELLATION_COMBAT_OK tiers=1,2,10 hit_callbacks=%d reverse_events=%d" % [
			_hit_callbacks, _reverse_area_events, 
		]
	)
	quit(0)


func _verify_tier_names() -> bool:
	var level_script: = load(LEVEL_SCRIPT_PATH) as Script
	if level_script == null:
		return _fail("level script load")
	var level: Node = level_script.new() as Node
	var expected_tiers: = {
		1: "一阶", 
		2: "二阶", 
		10: "十阶", 
	}
	for tier: int in expected_tiers:
		level.set("current_tier", tier)
		for index in range(EXPECTED_BOSS_NAMES.size()):
			var config: Dictionary = level.call("get_level_monster_config", 47101 + index)
			var expected_name: = "%s %s" % [expected_tiers[tier], EXPECTED_BOSS_NAMES[index]]
			if str(config.get("name", "")) != expected_name:
				level.free()
				return _fail("tier name %d/%d: %s" % [tier, index, config.get("name", "")])
			var drops: Array = config.get("independent_drop_list", [])
			var crystal_drop_names: = ["zqjs", "zqjh"] if index < 7 else ["xwjs", "xwjh"]
			var expected_drop_names: Array = crystal_drop_names.duplicate()
			var drop_multiplier: = 5 if tier >= 7 else (3 if tier >= 3 else 1)
			var expected_drop_chances: = [0.2 * drop_multiplier, 0.1 * drop_multiplier]
			if index < EXPECTED_SKILL_BOOK_DROPS.size():
				expected_drop_names.append(EXPECTED_SKILL_BOOK_DROPS[index])
				expected_drop_chances.append(0.05 * drop_multiplier)
			if drops.size() != expected_drop_names.size():
				level.free()
				return _fail("drop count %d: %s" % [index, drops])
			for drop_index in range(expected_drop_names.size()):
				var expected_drop_x: = (
					float(drop_index) - float(expected_drop_names.size() - 1) * 0.5
				) * 36.0
				var expected_drop_value: = drop_multiplier * 2 if drop_index == 0 else drop_multiplier
				if str(drops[drop_index].get("name", "")) != expected_drop_names[drop_index]\
				or int(drops[drop_index].get("value", 0)) != expected_drop_value\
				or not is_equal_approx(float(drops[drop_index].get("chance", 0.0)), expected_drop_chances[drop_index])\
				or not (drops[drop_index].get("spawn_offset", Vector2.ZERO) as Vector2).is_equal_approx(
							Vector2(expected_drop_x, 0.0)
						):
					level.free()
					return _fail("drop %d/%d: %s" % [index, drop_index, drops[drop_index]])
	for tier in [3, 6, 7]:
		level.set("current_tier", tier)
		var boundary_config: Dictionary = level.call("get_level_monster_config", 47101)
		var boundary_drops: Array = boundary_config.get("independent_drop_list", [])
		var expected_multiplier: = 3 if tier <= 6 else 5
		if boundary_drops.size() != 3:
			level.free()
			return _fail("drop boundary count tier %d" % tier)
		for drop_index in range(boundary_drops.size()):
			var base_chance: float = [0.2, 0.1, 0.05][drop_index]
			var expected_value: = expected_multiplier * 2 if drop_index == 0 else expected_multiplier
			if int(boundary_drops[drop_index].get("value", 0)) != expected_value\
			or not is_equal_approx(
						float(boundary_drops[drop_index].get("chance", 0.0)), 
						base_chance * expected_multiplier
					):
				level.free()
				return _fail("drop boundary tier %d/%d: %s" % [tier, drop_index, boundary_drops[drop_index]])
	level.set("current_tier", 10)
	var summon_config: Dictionary = level.call("get_level_monster_config", 47115)
	if str(summon_config.get("name", "")) != "星宿侍从":
		level.free()
		return _fail("summon tier prefix")

	var monster_scene: = load(BASE_MONSTER_SCENE_PATH) as PackedScene
	var display_monster: = monster_scene.instantiate()
	display_monster.process_mode = Node.PROCESS_MODE_DISABLED
	display_monster.set("my_mr_name", "二阶 轸宿")
	display_monster.set("SHp", 100)
	display_monster.set("Hp", 100)
	root.add_child(display_monster)
	var blood_scene: = load(BOSS_BLOOD_SCENE_PATH) as PackedScene
	var blood_bar: = blood_scene.instantiate()
	blood_bar.set("GetObj", display_monster)
	root.add_child(blood_bar)
	await create_timer(0.05, false).timeout
	var label: = blood_bar.get_node_or_null("MonsterName") as Label
	if label == null or label.text.strip_edges() != "二阶 轸宿":
		blood_bar.queue_free()
		display_monster.queue_free()
		level.free()
		return _fail("battle blood-bar name")
	blood_bar.queue_free()
	display_monster.queue_free()
	level.free()
	await process_frame
	return true


func _verify_hover_attributes() -> bool:
	var level_info_script: = load(LEVEL_INFO_SCRIPT_PATH) as Script
	var head_scene: = load(MONSTER_HEAD_SCENE_PATH) as PackedScene
	if level_info_script == null or head_scene == null:
		return _fail("hover resources")
	var level_info: Node = level_info_script.new() as Node
	level_info.set("TargetStagePath", "res://Scene/Level/Level_esbxx.tscn")
	var all_level_info: Dictionary = level_info.get("LevelInfo")
	var constellation_info: Dictionary = all_level_info.get("挑战28星宿", {})
	var monsters: Array = constellation_info.get("MonsterList", [])
	if monsters.size() != EXPECTED_BOSS_NAMES.size():
		level_info.free()
		return _fail("hover monster count %d" % monsters.size())
	for index in range(monsters.size()):
		var entry: Dictionary = monsters[index]
		var config_id: = int(entry.get("ConfigId", 0))
		var tier: = index % 10 + 1
		if config_id != 47101 + index:
			level_info.free()
			return _fail("hover config id %d=%d" % [index, config_id])
		var config: Dictionary = level_info.call(
			"_get_level_monster_config", "", config_id, tier
		)
		if config.is_empty() or int(config.get("hp", 0)) != 1500000 * tier\
		or float(config.get("speed", 0.0)) != 4.0:
			level_info.free()
			return _fail("hover config %d/%d" % [config_id, tier])
		var head: = head_scene.instantiate()
		head.set("MonsterName", str(entry.get("Name", "")))
		head.set("MonsterScenePath", "")
		head.set("LevelMonsterConfig", config)
		var attr_data: Dictionary = head.call("_get_scene_attr_data")
		if int(attr_data.get("生命", 0)) != 1500000 * tier\
		or int(attr_data.get("基础攻击", 0)) != 10000 * tier\
		or not attr_data.has("攻击"):
			head.free()
			level_info.free()
			return _fail("hover attributes %d/%d" % [config_id, tier])
		var panel: = head.call("_create_monster_attr_panel") as Control
		var panel_text: = _collect_label_text(panel)
		if "暂无属性数据" in panel_text or str(config.get("name", "")) not in panel_text:
			panel.free()
			head.free()
			level_info.free()
			return _fail("hover panel %d: %s" % [config_id, panel_text])
		panel.free()
		head.free()
	level_info.free()
	return true


func _collect_label_text(node: Node) -> String:
	var result: = ""
	if node is Label:
		result = (node as Label).text + "\n"
	for child in node.get_children():
		result += _collect_label_text(child)
	return result


func _verify_frame_collision_alignment() -> bool:
	var registration: = Vector2(96.35, 96.3)
	var projectile_script: = load(PROJECTILE_SCRIPT_PATH) as Script
	var projectile: Node = projectile_script.new() as Node
	projectile.process_mode = Node.PROCESS_MODE_ALWAYS
	projectile.call("configure", {
		"position": Vector2.ZERO, 
		"right": false, 
		"frame_root": "res://Art/Constellations/Boss/158/skill1", 
		"frame_count": 6, 
		"frame_fps": 24.0, 
		"loop_visual": false, 
		"visual_registration": registration, 
		"visual_faces_right": false, 
		"collision_size": Vector2.ZERO, 
		"collision_offset": registration, 
		"damage_enabled": false, 
		"lifetime": 1.0, 
	})
	root.add_child(projectile)
	await physics_frame
	if not _collision_matches_frame(projectile, registration, 0):
		projectile.queue_free()
		return false
	await create_timer(0.11, false).timeout
	var current_frame: = int(projectile.get("_last_collision_frame"))
	if current_frame <= 0 or not _collision_matches_frame(projectile, registration, current_frame):
		projectile.queue_free()
		return false
	projectile.queue_free()
	await process_frame
	return true


func _collision_matches_frame(
	projectile: Node, registration: Vector2, frame_index: int
) -> bool:
	var path: = "res://Art/Constellations/Boss/158/skill1/%d.png" % (frame_index + 1)
	var geometry: = MonsterAtlasSequence.frame_geometry_for_source_path(path)
	if not bool(geometry.get("has_visual", false)):
		return _fail("collision texture %d" % frame_index)
	var expected_size: = geometry.get("size", Vector2.ONE) as Vector2
	var expected_center: = registration + (geometry.get("center", Vector2.ZERO) as Vector2)
	var shape_node: = projectile.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if shape_node == null or not (shape_node.shape is RectangleShape2D):
		return _fail("collision shape %d" % frame_index)
	var actual_size: = (shape_node.shape as RectangleShape2D).size
	if not actual_size.is_equal_approx(expected_size):
		return _fail("collision size frame %d: %s != %s" % [frame_index, actual_size, expected_size])
	if not shape_node.position.is_equal_approx(expected_center):
		return _fail(
			"collision center frame %d: %s != %s" % [
				frame_index, shape_node.position, expected_center, 
			]
		)
	return true


func _verify_empty_visual_frames() -> bool:
	var projectile_script: = load(PROJECTILE_SCRIPT_PATH) as Script
	var fully_empty: Node = projectile_script.new() as Node
	fully_empty.process_mode = Node.PROCESS_MODE_ALWAYS
	fully_empty.call("configure", {
		"frame_root": "res://Art/Constellations/Boss/156/skill1", 
		"frame_count": 1, 
		"frame_fps": 30.0, 
		"loop_visual": false, 
		"collision_size": Vector2.ZERO, 
		"damage_enabled": true, 
		"damage_duration": 1.0, 
		"lifetime": 1.0, 
	})
	root.add_child(fully_empty)
	await process_frame
	var empty_geometry: Dictionary = fully_empty.call(
		"_frame_geometry", "res://Art/Constellations/Boss/156/skill1/1.png"
	)
	var empty_hit_box: = fully_empty.get_node_or_null("middle/HitBox") as Area2D
	if bool(empty_geometry.get("has_visual", true))\
	or bool(fully_empty.get("_current_frame_has_visual"))\
	or (empty_hit_box != null and empty_hit_box.monitoring):
		fully_empty.queue_free()
		return _fail("fully transparent frame can damage")
	fully_empty.queue_free()
	await process_frame

	var looping: Node = projectile_script.new() as Node
	looping.process_mode = Node.PROCESS_MODE_ALWAYS
	looping.call("configure", {
		"frame_root": "res://Art/Constellations/Boss/150/skill1", 
		"frame_count": 10, 
		"frame_fps": 30.0, 
		"loop_visual": true, 
		"collision_size": Vector2.ZERO, 
		"damage_enabled": true, 
		"damage_duration": 2.0, 
		"lifetime": 2.0, 
	})
	root.add_child(looping)
	await process_frame
	var looping_hit_box: = looping.get_node_or_null("middle/HitBox") as Area2D
	if looping_hit_box == null or not bool(looping.get("_current_frame_has_visual")):
		looping.queue_free()
		return _fail("visible frame collision did not start")
	looping.set("_elapsed", 7.0 / 30.0)
	looping.call("_sync_collision_to_visual_frame", true)
	looping.call("_update_damage_window")
	await process_frame
	if bool(looping.get("_current_frame_has_visual")) or looping_hit_box.monitoring:
		looping.queue_free()
		return _fail("transparent middle frame monitoring")
	looping.set("_elapsed", 10.0 / 30.0)
	looping.call("_sync_collision_to_visual_frame", true)
	looping.call("_update_damage_window")
	await process_frame
	if not bool(looping.get("_current_frame_has_visual")) or not looping_hit_box.monitoring:
		looping.queue_free()
		return _fail("visible frame monitoring did not resume")
	looping.queue_free()
	await process_frame
	return true


func _verify_projectile_damage_window() -> bool:
	var arena: = Node2D.new()
	root.add_child(arena)
	var monster_scene: = load(BASE_MONSTER_SCENE_PATH) as PackedScene
	var boss: = monster_scene.instantiate()
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	boss.set("is_boss", false)
	boss.set("level", 90)
	boss.set("Htarget", 10000)
	boss.set("crit", 0)
	boss.set("lucky", 0)
	boss.set("ar", 10000)
	boss.set("sp", 10000)
	boss.set("objattackDic", {"hit1": _attack_data()})
	arena.add_child(boss)

	var hero_scene: = load(BASE_HERO_SCENE_PATH) as PackedScene
	var hero: = hero_scene.instantiate() as Node2D
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.position = Vector2(500, 300)
	arena.add_child(hero)
	hero.set_process(false)
	hero.set_physics_process(false)
	hero.set_meta("pet_turtle_link_unit_ref", false)
	await process_frame
	var hurt_area: = hero.get_node_or_null("base_damagebox/HurtBox") as Area2D
	var hurt_shape: = hero.get_node_or_null("base_damagebox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_area == null or hurt_shape == null:
		arena.queue_free()
		return _fail("hero hurt area")
	var hero_shape: = RectangleShape2D.new()
	hero_shape.size = Vector2(60, 120)
	hurt_shape.shape = hero_shape
	hurt_shape.disabled = false
	hurt_area.collision_layer = 896
	hurt_area.collision_mask = 4
	hurt_area.monitoring = true
	hurt_area.monitorable = true
	hurt_area.area_entered.connect(_on_reverse_area_entered)

	var role_prop_node: = root.get_node_or_null("RoleProp")
	if role_prop_node == null:
		arena.queue_free()
		return _fail("RoleProp autoload")
	var base_properties: Dictionary = role_prop_node.get("baseroleprop")
	var role_properties: Dictionary = role_prop_node.get("roleprop")
	base_properties["Level"] = 90
	base_properties["SHp"] = 100000
	role_properties["SHp"] = 100000
	role_properties["Hp"] = 100000
	role_properties["Def"] = 0
	role_properties["Mdef"] = 0
	role_properties["Miss"] = 0
	role_properties["CritReduce"] = 0
	role_properties["Toughness"] = 0
	role_properties["sp"] = 0
	hero.set("needProtect", false)
	hero.set("IsDeath", false)
	await create_timer(0.05, false).timeout
	role_properties["Hp"] = int(role_properties.SHp)

	var delayed: = _spawn_damage_projectile(boss, hero.global_position, 0.2)
	var hp_before: = int(role_properties.Hp)
	if not await _wait_for_projectile_elapsed(delayed, 0.12):
		arena.queue_free()
		return _fail("delayed projectile did not advance")
	if int(role_properties.Hp) != hp_before:
		var delayed_hit_box: = delayed.get_node_or_null("middle/HitBox") as Area2D
		arena.queue_free()
		return _fail(
			"damage before active window hp=%d/%d elapsed=%.3f monitoring=%s callbacks=%d reverse=%d" % [
				int(role_properties.Hp), hp_before, float(delayed.get("_elapsed")), 
				str(delayed_hit_box.monitoring if delayed_hit_box != null else null), 
				_hit_callbacks, _reverse_area_events, 
			]
		)
	if not await _wait_for_projectile_elapsed(delayed, 0.32):
		arena.queue_free()
		return _fail("active projectile did not advance")
	if int(role_properties.Hp) >= hp_before or _hit_callbacks != 1:
		var active_hit_box: = delayed.get_node_or_null("middle/HitBox") as Area2D
		var active_shape: = delayed.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
		var overlap_count: = active_hit_box.get_overlapping_areas().size()\
		if active_hit_box != null else -1
		arena.queue_free()
		return _fail(
			(
				"active window damage hp=%d/%d elapsed=%.3f monitoring=%s overlaps=%d "
				+ "projectile=%s shape=%s hurt=%s callbacks=%d reverse=%d"
			) % [
				int(role_properties.Hp), hp_before, float(delayed.get("_elapsed")), 
				str(active_hit_box.monitoring if active_hit_box != null else null), 
				overlap_count, str(delayed.global_position), 
				str(active_shape.global_position if active_shape != null else Vector2.ZERO), 
				str(hurt_shape.global_position), _hit_callbacks, _reverse_area_events, 
			]
		)
	if delayed.get("_hit_count") != 1:
		arena.queue_free()
		return _fail("single accepted hit")

	delayed.queue_free()
	await process_frame
	hero.set("needProtect", true)
	role_properties["Hp"] = hp_before
	var protected: = _spawn_damage_projectile(boss, hero.global_position, 0.0)
	if not await _wait_for_projectile_elapsed(protected, 0.25):
		arena.queue_free()
		return _fail("protected projectile did not advance")
	if int(role_properties.Hp) != hp_before or _hit_callbacks != 1:
		arena.queue_free()
		return _fail("protected player damage")
	if int(protected.get("_hit_count")) != 0:
		arena.queue_free()
		return _fail("protected hit count")
	if _reverse_area_events != 0:
		arena.queue_free()
		return _fail("reverse player detection")

	protected.queue_free()
	await process_frame
	hero.set("needProtect", false)
	role_properties["Hp"] = hp_before
	var stone_frame_offset: = Vector2(-471.55, 151.5)
	var stone_spawn_position: = hurt_shape.global_position - stone_frame_offset
	var stone: = _spawn_monster140_stone_projectile(boss, stone_spawn_position, false)
	if not await _wait_for_projectile_elapsed(stone, 0.76):
		arena.queue_free()
		return _fail("Monster140Bullet1 did not advance")
	if int(role_properties.Hp) >= hp_before or int(stone.get("_hit_count")) != 1\
	or _hit_callbacks != 2:
		var stone_shape: = stone.get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
		arena.queue_free()
		return _fail(
			"Monster140Bullet1 damage hp=%d/%d hits=%d callbacks=%d shape=%s hurt=%s" % [
				int(role_properties.Hp), hp_before, int(stone.get("_hit_count")), 
				_hit_callbacks, 
				str(stone_shape.global_position if stone_shape != null else Vector2.ZERO), 
				str(hurt_shape.global_position), 
			]
		)
	stone.queue_free()
	await process_frame
	role_properties["Hp"] = hp_before
	var mirrored_offset: = Vector2(471.55, 151.5)
	var mirrored_spawn_position: = hurt_shape.global_position - mirrored_offset
	var mirrored_stone: = _spawn_monster140_stone_projectile(
		boss, mirrored_spawn_position, true
	)
	if not await _wait_for_projectile_elapsed(mirrored_stone, 0.76):
		arena.queue_free()
		return _fail("mirrored Monster140Bullet1 did not advance")
	if int(role_properties.Hp) >= hp_before\
	or int(mirrored_stone.get("_hit_count")) != 1 or _hit_callbacks != 3:
		var mirrored_shape: = mirrored_stone.get_node_or_null(
			"middle/HitBox/Hit_Box"
		) as CollisionShape2D
		arena.queue_free()
		return _fail(
			"mirrored Monster140Bullet1 damage hp=%d/%d hits=%d callbacks=%d shape=%s hurt=%s" % [
				int(role_properties.Hp), hp_before, 
				int(mirrored_stone.get("_hit_count")), _hit_callbacks, 
				str(mirrored_shape.global_position if mirrored_shape != null else Vector2.ZERO), 
				str(hurt_shape.global_position), 
			]
		)
	mirrored_stone.queue_free()
	arena.queue_free()
	await process_frame
	return true


func _spawn_damage_projectile(
	boss: Node, spawn_position: Vector2, delay: float
) -> Node:
	var projectile_script: = load(PROJECTILE_SCRIPT_PATH) as Script
	var projectile: Node = projectile_script.new() as Node
	projectile.process_mode = Node.PROCESS_MODE_ALWAYS
	projectile.call("configure", {
		"owner": boss, 
		"position": spawn_position, 
		"right": true, 
		"hit_name": "hit1", 
		"attack_data": _attack_data(), 
		"skill_name": "ConstellationDamageProbe", 
		"collision_size": Vector2(80, 140), 
		"damage_enabled": true, 
		"damage_enable_delay": delay, 
		"hit_delay": delay, 
		"damage_duration": 0.45, 
		"hit_interval": 0.1, 
		"max_hits": 1, 
		"lifetime": 0.8, 
		"expire_on_hit": false, 
		"hit_callback": Callable(self, "_on_projectile_hit"), 
	})
	boss.get_node("Bullet").add_child(projectile)
	return projectile


func _spawn_monster140_stone_projectile(
	boss: Node, spawn_position: Vector2, right_facing: bool
) -> Node:
	var projectile_script: = load(PROJECTILE_SCRIPT_PATH) as Script
	var projectile: Node = projectile_script.new() as Node
	projectile.process_mode = Node.PROCESS_MODE_ALWAYS
	projectile.call("configure", {
		"owner": boss, 
		"position": spawn_position, 
		"right": right_facing, 
		"hit_name": "hit1", 
		"attack_data": {
			"power": 500, 
			"hurtBack": [-6.0, -5.0], 
			"attackKind": "physics", 
			"HitProtect": 0, 
			"attackInterval": 999.0 / 24.0, 
			"hitMaxCount": 99, 
		}, 
		"skill_name": "Monster140Bullet1", 
		"frame_root": "res://Art/Constellations/Boss/140/skill1", 
		"frame_count": 25, 
		"frame_fps": 24.0, 
		"loop_visual": false, 
		"visual_registration": Vector2(-195.05, 94.0), 
		"visual_faces_right": false, 
		"collision_size": Vector2.ZERO, 
		"collision_offset": Vector2(-195.05, 94.0), 
		"damage_enabled": true, 
		"damage_duration": 25.0 / 24.0, 
		"hit_interval": 999.0 / 24.0, 
		"max_hits": 99, 
		"lifetime": 25.0 / 24.0, 
		"expire_on_hit": false, 
		"hit_callback": Callable(self, "_on_projectile_hit"), 
	})
	boss.get_node("Bullet").add_child(projectile)
	return projectile


func _attack_data() -> Dictionary:
	return {
		"power": 1000, 
		"hurtBack": [0.0, 0.0], 
		"attackKind": "physics", 
		"HitProtect": 0, 
		"attackInterval": 0.1, 
		"hitMaxCount": 1, 
	}


func _on_projectile_hit(_projectile: Node, _hero: Node) -> void :
	_hit_callbacks += 1


func _on_reverse_area_entered(_area: Area2D) -> void :
	_reverse_area_events += 1


func _wait_for_projectile_elapsed(projectile: Node, target_elapsed: float) -> bool:
	for _frame in range(180):
		if not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			return false
		if float(projectile.get("_elapsed")) >= target_elapsed:
			return true
		await physics_frame
	return false


func _fail(reason: String) -> bool:
	push_error("CONSTELLATION_COMBAT_FAIL %s" % reason)
	quit(1)
	return false
