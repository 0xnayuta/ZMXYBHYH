extends "res://Script/Test/NorthMechanicsProbe.gd"

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var reference: = load("res://Scene/Level/Level_49.tscn").instantiate() as Game4ImportedLevel
	get_tree().root.add_child(reference)
	get_tree().current_scene = reference
	await get_tree().create_timer(1).timeout
	reference.create_control.stop()
	reference.set_physics_process(false)
	reference.Role_.set_physics_process(false)
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Hp = 10000000
	reference.current_stage = 2
	reference._camera_room = 2
	reference._camera_left_limit = 0
	var reference_limits: Array[float] = []
	for i in range(120):
		reference._update_screen_bounds(1.0 / 60)
		reference_limits.append(reference._camera_left_limit)
	reference.queue_free()
	await get_tree().process_frame
	var level: = await _level(77)
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	level._camera_left_limit = 0
	level._camera_room = 2
	level.current_stage = 2
	for i in range(120):
		level._update_screen_bounds(1.0 / 60)
		_check(is_equal_approx(level._camera_left_limit, reference_limits[i]), "镜头限位过渡与未央宫不同")
	_check(level.my_camera.zoom == Vector2.ONE, "画面被放大")
	_check(level.my_camera.position_smoothing_enabled and level.my_camera.limit_smoothed and not level.my_camera.top_level, 
		"未复用未央宫正常跟随和平滑限制")

	level.current_stage = 1
	level._camera_room = 1
	level._camera_left_limit = 0
	level._activate_trigger(0)
	level.Role_.position = Vector2(1100, 960)
	level.Role_.set_physics_process(true)
	level.set_physics_process(true)
	var actor: = await _boss(level, 3357)
	actor.position = Vector2(950, 989)
	Input.action_press("move_right")
	await get_tree().create_timer(0.8).timeout
	Input.action_release("move_right")
	_check(level.Role_.position.x < 1210, "未清怪越过下一波物理边界")
	_check(level.current_stage == 1, "未清怪提前开波")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_weiyang_camera.png")
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	var hero: = level.Role_ as BaseHero
	hero.NoDeBuff = false
	for buff in hero.buff.get_children(): buff.queue_free()
	await get_tree().process_frame
	for ratio in [0.5, 0.5, 0.5, 50.0]:
		Global.AddBuff(hero.buff, {"Name": "speed_down", "value": ratio, "AddTime": 0.4, 
			"ReduceInterval": 0, "CanAdd": true, "DeBuff": true})
		await get_tree().create_timer(0.15).timeout
		print("NORTH_SLOW ", ratio, " speed=", hero.walk_speed, " buffs=", hero.buff.get_child_count())
		_check(hero.walk_speed == 120, "重复50%减速使人物无法移动")
	Global.AddBuff(hero.buff, {"Name": "speed_down", "value": 0.25, "AddTime": 0.2, 
		"ReduceInterval": 0, "CanAdd": false, "DeBuff": true})
	await get_tree().create_timer(0.05).timeout
	_check(hero.walk_speed == 180, "刷新减速没有更新实际速度")
	hero.set_physics_process(true)
	var old_x: = hero.position.x
	Input.action_press("move_left")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("move_left")
	_check(hero.position.x < old_x - 5, "减速后实际按键不能移动")
	await get_tree().create_timer(0.3).timeout
	_check(hero.walk_speed == 240, "减速结束没有恢复速度")
	await _dispose(level)
	level = await _level(77)
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	var terrain: = level.get_node("OriginalTerrain")
	var checked_wind: = false
	for record: Dictionary in terrain.source_data["objects"]:
		if record["type"] == "WindEntity":
			var rect: Array = record["rect"]
			level.Role_.position = Vector2(float(rect[0]) + float(rect[2]) / 2, float(rect[1]) + float(rect[3]) / 2)
			var before: Vector2 = level.Role_.position
			terrain._physics_process(0.2)
			_check(level.Role_.position == before, "风区仍推动人物")
			checked_wind = true
			break
	_check(checked_wind, "没有实际测试原版风区")
	_check(terrain._source_objects.filter( func(record): return record["type"] == "WindEntity").is_empty(), "风区视觉或实体仍被创建")
	await _dispose(level)
	var exit_level: = load("res://Scene/Level/Level_77.tscn").instantiate() as NorthContinentLevel
	exit_level.set_script(load("res://Script/Test/NorthExitProbeLevel.gd"))
	exit_level.stage_number = 77
	get_tree().root.add_child(exit_level)
	get_tree().current_scene = exit_level
	await get_tree().create_timer(1).timeout
	exit_level.create_control.stop()
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Hp = 10000000
	exit_level.Role_.needProtect = true
	exit_level.Role_.set_meta("pet_turtle_link_unit_ref", false)
	exit_level.set_physics_process(false)
	exit_level.Role_.set_physics_process(false)
	exit_level._spawn_runtime_ready = false
	exit_level._on_exit_2_body_entered(exit_level.Role_)
	await get_tree().create_timer(0.1).timeout
	_check(exit_level.get("exit_requests") == 0 and exit_level.can_exit, "碰出口未按W就结算")
	Input.action_press("Exit")
	exit_level._physics_process(0)
	_check(exit_level.get("exit_requests") == 1, "出口按W没有结算")
	Input.action_release("Exit")
	await _dispose(exit_level)
	PlayerData.player_data = old_data
	print("NORTH_REQUESTED_FIXES ", _checks, " checks failures=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
