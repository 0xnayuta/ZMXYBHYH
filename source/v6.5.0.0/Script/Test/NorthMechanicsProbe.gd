extends Node

var _checks: = 0
var _failures: Array[String] = []
var _shots: Array[Dictionary] = []

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(150.0).timeout.connect( func(): get_tree().quit(2))

func _check(value: bool, message: String) -> void :
	_checks += 1
	if not value:
		_failures.append(message)
		push_error("NORTH_MECHANIC_FAIL " + message)

func _level(number: int, hidden: bool = false) -> NorthContinentLevel:
	RoleProp.roleprop.Hp = 10000000
	var path: = "res://Scene/Level/Level_%d%s.tscn" % [number, "_hidden" if hidden else ""]
	var level: = load(path).instantiate() as NorthContinentLevel
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	await get_tree().create_timer(0.9).timeout
	level.create_control.stop()
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Hp = 10000000
	level.Role_.needProtect = true
	level.Role_.set_meta("pet_turtle_link_unit_ref", false)
	return level

func _boss(level: NorthContinentLevel, id: int) -> BaseMonster:
	var actor: = Global.Create_Monster(id, level.monster, level.Role_.position + Vector2(220, 0))
	actor.set_physics_process(false)
	actor._next_cast = Time.get_ticks_msec() + 600000
	actor.set_meta("allow_position_y_over_800", true)
	await get_tree().create_timer(0.4).timeout
	actor.set_physics_process(false)
	actor.is_attacking = false
	actor.source_projectile_spawned.connect( func(sequence, projectile):
		_shots.append({"sequence": sequence, "motion": projectile.motion_velocity, 
			"time": Time.get_ticks_msec(), "position": projectile.spawn_global_position, "projectile": projectile}))
	return actor

func _action(actor: BaseMonster, key: String) -> StringName:
	for action: StringName in actor._skill_actions:
		if actor._skill_actions[action]["key"] == key: return action
	return &""

func _shots_for(sequence: String) -> Array:
	return _shots.filter( func(shot): return shot["sequence"] == sequence)

func _dispose(level: NorthContinentLevel) -> void :
	level.queue_free()
	get_tree().current_scene = null
	await get_tree().create_timer(0.2).timeout
	_shots.clear()

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	var old_data: = PlayerData.player_data.duplicate(true)
	var level: = await _level(76)
	var boss: = await _boss(level, 3353)
	boss.cast_action(_action(boss, "effect3"))
	await get_tree().create_timer(1.8).timeout
	_check(_shots_for("effect3_1").size() == 6, "青霄玉女没有六枚分时冰晶")
	for shot in _shots_for("effect3_1"):
		_check(shot["position"].y < boss.global_position.y - 500, "冰晶没有从原版上空发出")
	await _dispose(level)
	level = await _level(78)
	boss = await _boss(level, 3382)
	_check(boss.mr_ani.sprite_frames.get_frame_count(&"hit1") == 55, "天气祖巫骨骼动作不是原版 55 帧")
	boss.cast_action(_action(boss, "effect2"))
	await get_tree().create_timer(1.5).timeout
	_check(boss._sons.size() == 1 and boss._sons[0].monster_kind == 3383, "春回雾暖没有按原版延时召唤")
	_check( not _shots_for("effect2_overlay").is_empty(), "天气祖巫缺少骨骼技能图层")
	await _dispose(level)
	level = await _level(80)
	boss = await _boss(level, 3409)
	boss.cast_action(_action(boss, "effect2"))
	await get_tree().create_timer(2.4).timeout
	var balls: = _shots_for("effect2_1")
	print("NORTH_GOLD_COUNT=", balls.size())
	_check(balls.size() == 4, "百眼魔君不是四枚金光")
	for ball in balls:
		var projectile = ball["projectile"]
		if is_instance_valid(projectile): _check(projectile.bounce, "百眼魔君金光没有反弹")
	for enemy in level.monster.get_children(): enemy.queue_free()
	for id in level._active_points:
		level._point_states[id]["spawned"] = level._point_states[id]["target"]
		level._point_states[id]["instances"] = []
	await get_tree().process_frame
	level.set_physics_process(false)
	while level.current_stage < level.MAZE_WAVE_COUNT:
		level._update_stage_progression()
		for id in level._active_points:
			level._point_states[id]["spawned"] = level._point_states[id]["target"]
			level._point_states[id]["instances"] = []
	level.Role_.position = Vector2(210, 430)
	level.Role_.velocity = Vector2.ZERO
	await get_tree().create_timer(0.4).timeout
	Input.action_press("Exit")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("Exit")
	_check(level.maze_room == 7, "幻境阁左门没有进入百眼魔君房间")
	_check( not level.Role_.IsDeath and level.Role_.position.y < 470, "幻境阁换房后角色穿过地面")
	await _dispose(level)
	level = await _level(80, true)
	_check(level.hidden_original_room and level.source_map == "huanjinggeyincang", "幻境阁隐藏分支不是原版房间")
	boss = await _boss(level, 3421)
	_check(boss.my_mr_name == "盘丝大仙", "幻境阁隐藏分支 boss 错误")
	await _dispose(level)
	level = await _level(81)
	boss = await _boss(level, 3422)
	boss.to_hero()
	_check(boss._facing() == 1.0, "空间祖巫没有保持原版固定朝向")
	boss.cast_action(_action(boss, "effect3"))
	await get_tree().create_timer(1.0).timeout
	var shadows: = _shots_for("effect3_2")
	_check(shadows.size() == 1, "空间祖巫没有生成地面阴影")
	if shadows.size() == 1:
		level.Role_.set_physics_process(false)
		level.Role_.position = shadows[0]["position"] - Vector2(0, 39)
		await get_tree().create_timer(0.6).timeout
		_check(_shots_for("effect3_4").size() == 1, "站在空间祖巫阴影半秒没有触发后续攻击")
	await _dispose(level)
	level = await _level(82)
	var terrain: = level.get_node("OriginalTerrain")
	var statue: Dictionary = {}
	for record: Dictionary in terrain._source_objects:
		if record["type"] == "DragonItemEntity": statue = record;break
	terrain._break_dragon_statue(statue)
	await get_tree().create_timer(0.6).timeout
	var lit: = false
	for record: Dictionary in terrain._source_objects:
		if record["type"] == "LightEntity" and record.get("lit_until", 0) > terrain._clock: lit = true
	_check(lit, "夙夜径击碎龙珠没有点亮光源")
	await _dispose(level)
	level = await _level(84)
	boss = await _boss(level, 3528)
	boss.to_hero()
	_check(boss._facing() == -1.0, "时间祖巫没有保持原版固定朝向")
	boss.cast_action(_action(boss, "effect1"))
	await get_tree().create_timer(3.2).timeout
	_check(_shots_for("effect1_1").size() == 1 and _shots_for("effect1_2").size() == 1, "时间祖巫缺少两次风影")
	var left: = _shots_for("effect1_1")
	var right: = _shots_for("effect1_2")
	if not left.is_empty() and not right.is_empty():
		_check(left[0]["position"].x < right[0]["position"].x and left[0]["position"].y == 0, "时间祖巫风影起点不是屏幕两侧上空")
	await _dispose(level)
	level = await _level(85)
	boss = await _boss(level, 3539)
	boss.cast_action(_action(boss, "effect4"))
	await get_tree().create_timer(1.9).timeout
	_check(_shots_for("effect4_1").size() == 20, "星域教主没有两轮各十枚魔魂")
	boss.cast_action(_action(boss, "effect2"))
	_shots.clear()
	await get_tree().create_timer(6.2).timeout
	_check(_shots_for("effect2_1").size() == 8, "星域教主幻雷荆棘不是八次")
	var moving: = Global.Create_Monster(3535, level.monster, Vector2(1000, 200))
	moving.set_meta("allow_position_y_over_800", true)
	await get_tree().create_timer(0.6).timeout
	_check( not moving._sky_path.is_empty() and moving.global_position.x < 1000, "星域小怪没有按原版路径飞入")
	await _dispose(level)
	var map: = load("res://Scene/Main_menu/Map_8.tscn").instantiate() as Map8
	get_tree().root.add_child(map)
	PlayerData.player_data.erase("云川")
	PlayerData.player_data.erase("北俱芦洲通关_76")
	PlayerData.player_data.erase("苍梧渊")
	map._update_level_progression()
	_check(map.get_node("Level_76").disabled and map.get_node("Level_77").disabled, "未通前置时地图未锁定")
	PlayerData.player_data["云川"] = 1
	map._update_level_progression()
	_check( not map.get_node("Level_76").disabled and map.get_node("Level_77").disabled, "云川通关没有只开放苍梧渊")
	map.queue_free()
	await get_tree().process_frame
	PlayerData.player_data = old_data
	print("NORTH_MECHANICS_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
