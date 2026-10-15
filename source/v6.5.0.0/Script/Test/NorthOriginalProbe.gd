extends Node

var _checks: = 0
var _failures: Array[String] = []

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(180.0).timeout.connect( func(): get_tree().quit(2))

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("NORTH_FAIL " + message)

func _run() -> void :
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	Global.Is_Show = true
	Global.cd_path = ""
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	var progression: = PlayerData.player_data.duplicate(true)
	for number in range(76, 86):
		var level: = load("res://Scene/Level/Level_%d.tscn" % number).instantiate() as NorthContinentLevel
		get_tree().root.add_child(level)
		get_tree().current_scene = level
		await get_tree().create_timer(1.0).timeout
		level.create_control.stop()
		var hero: BaseHero = level.Role_
		hero.needProtect = true
		hero.set_meta("pet_turtle_link_unit_ref", false)
		RoleProp.roleprop.SHp = 10000000
		RoleProp.roleprop.Hp = 10000000
		var terrain: = level.get_node("OriginalTerrain")
		_check(level.get_node("wall/floor").disabled, "%d 占位平路仍在" % number)
		_check(terrain.source_data["grounds"].size() > 0, "%d 缺少原版地形" % number)
		_check( not terrain._backgrounds.is_empty(), "%d 缺少原版背景" % number)
		_check(level.monster.position == Vector2.ZERO and level.hero.position == Vector2.ZERO, "%d 场景坐标错误" % number)
		_check( not level.check_can_exit(), "%d 未击败 boss 就能通关" % number)
		if number in [76, 79]:
			_check(level.my_camera.max_bottom > 1500, "%d 纵向相机没有开放" % number)
		if number == 85:
			var old_y: = hero.position.y
			Input.action_press("Exit")
			await get_tree().create_timer(0.2).timeout
			Input.action_release("Exit")
			_check(hero.position.y < old_y - 10, "星域实际向上飞行失败")
			_check(hero.gravity == 0, "星域没有关闭重力")
		else:
			_check( not hero.IsDeath, "%d 出生点掉落死亡" % number)
			Input.action_press("move_right")
			await get_tree().create_timer(0.15).timeout
			Input.action_release("move_right")
		for enemy in level.monster.get_children():
			enemy.queue_free()
		await get_tree().process_frame
		var boss_id: = int(level._boss_ids[0])
		var boss: = Global.Create_Monster(boss_id, level.monster, hero.position + Vector2(220, 0))
		boss.set_meta("allow_position_y_over_800", true)
		await get_tree().create_timer(0.4).timeout
		boss.set_physics_process(false)
		boss.is_attacking = false
		var raw: = NorthOriginalData.monster_record(boss_id)
		_check(boss.SHp in [int(raw["hpMax"]), int(raw["hpMax"]) + 1], "%d 原版 boss 生命错误" % number)
		_check(boss.attack_in == int(raw["atk"]), "%d 原版 boss 攻击错误" % number)
		_check(boss._skill_actions.size() >= 3, "%d boss 技能缺失" % number)
		_check(boss.hurt_box.shape.size.x >= 35, "%d boss 受击判定为空" % number)
		for action in boss._skill_actions:
			_check(boss.mr_player.has_animation(action), "%d %s 动画不存在" % [number, action])
		boss.mr_ani.flip_h = false
		var right: Vector2 = boss._visual_offset(&"wait")
		boss.mr_ani.flip_h = true
		var left: Vector2 = boss._visual_offset(&"wait")
		_check(is_equal_approx(right.x, - left.x) and is_equal_approx(right.y, left.y), "%d 转向注册点错误" % number)
		boss.cast_action(boss._skill_actions.keys()[0])
		await get_tree().create_timer(0.3).timeout
		_check(boss.is_attacking, "%d boss 不能施法" % number)
		if number == 80:
			_check(level.MAZE_WAVE_COUNT == 3, "幻境阁不是固定三波")
		if number == 81:
			level.enter_void_space(boss)
			await get_tree().create_timer(0.3).timeout
			_check(level.in_void_space and level._void_units.size() == 4, "壶中洞天没有四只虚空怪")
			for unit in level._void_units: unit.Hp = 0
			await get_tree().create_timer(0.3).timeout
			_check( not level.in_void_space and boss.visible, "壶中洞天没有恢复第一空间")
		if number == 76:
			_check(terrain._moving.size() == 3 and terrain._collapsing.size() == 6, "苍梧渊移动/崩塌冰台数量不符")
		await RenderingServer.frame_post_draw
		var screenshot: = get_viewport().get_texture().get_image()
		screenshot.save_png("res://.codex_tmp/north_level_%d.png" % number)
		level.add_tg(number)
		_check(PlayerData.player_data.get("北俱芦洲通关_%d" % number, 0) == 1, "%d 独立进度写入失败" % number)
		print("NORTH_LEVEL_OK ", number)
		level.queue_free()
		get_tree().current_scene = null
		await get_tree().create_timer(0.3).timeout
	var menu: Map8 = load("res://Script/Main_menu/Map_8.gd").new()
	_check(menu._has_prerequisite(85), "星域前置进度不兼容")
	menu.free()

	var final_level: = load("res://Scene/Level/Level_85.tscn").instantiate() as NorthContinentLevel
	get_tree().root.add_child(final_level)
	get_tree().current_scene = final_level
	await get_tree().create_timer(0.8).timeout
	final_level.create_control.stop()
	final_level._spawn_runtime_ready = false
	final_level._boss_seen = true
	final_level.current_stage = 1
	for id in final_level._point_states:
		final_level._point_states[id]["spawned"] = final_level._point_states[id]["target"]
		final_level._point_states[id]["instances"] = []
	for enemy in final_level.monster.get_children(): enemy.queue_free()
	var final_hero: BaseHero = final_level.Role_
	final_hero.needProtect = true
	final_hero.set_meta("pet_turtle_link_unit_ref", false)
	RoleProp.roleprop.Hp = 10000000
	final_hero.position = Vector2(700, 300)
	final_hero.velocity = Vector2.ZERO
	await get_tree().create_timer(0.2).timeout
	_check(final_level.check_can_exit(), "星域击败全部 boss 后出口没有开放")
	Input.action_press("move_right")
	var elapsed: = 0.0
	while get_tree().current_scene == final_level and not final_level.can_exit and elapsed < 5.0:
		await get_tree().create_timer(0.1).timeout
		elapsed += 0.1
	Input.action_release("move_right")
	_check(get_tree().current_scene == final_level and final_level.can_exit, "星域出口未按W就结算或未正确检测人物")
	Input.action_press("Exit")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("Exit")
	await get_tree().create_timer(1.0).timeout
	_check(get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://Scene/Level/victory.tscn", "星域出口按W没有进入胜利场景")
	_check(PlayerData.player_data.get("北俱芦洲通关_85", 0) == 1 and PlayerData.player_data.get("星域", 0) == 1, "真实通关没有写入星域进度")
	PlayerData.player_data = progression
	print("NORTH_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
