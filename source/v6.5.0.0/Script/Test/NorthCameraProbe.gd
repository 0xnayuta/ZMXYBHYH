extends "res://Script/Test/NorthMechanicsProbe.gd"

func _visible_rect(level: NorthContinentLevel) -> Rect2:
	var size: Vector2 = level.get_viewport_rect().size / level.my_camera.zoom
	return Rect2(level.my_camera.get_screen_center_position() - size / 2, size)

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	for number in range(76, 86):
		var level: = await _level(number)
		level.set_physics_process(false)
		level.Role_.set_physics_process(false)
		for enemy in level.monster.get_children(): enemy.queue_free()
		await get_tree().process_frame
		level._active_points.clear()
		level._visited_triggers.clear()
		level._pending_triggers.clear()
		level._initialize_point_states()
		_check(level.my_camera.zoom == Vector2.ONE and _visible_rect(level).size == level.get_viewport_rect().size, 
			"%d 镜头改变了原有画面大小" % number)
		var starts: = NorthOriginalData.numbers(level._north_data["dungeon"]["sceneStart"])
		var index: = 1 if number in [76, 85] else 0
		level._activate_trigger(index)
		_check(is_equal_approx(level._battle_bounds.position.x, float(starts[mini(index, starts.size() - 1)])), "%d sceneStart错误" % number)
		_check(level._battle_bounds.size.x == float(level._north_data["dungeon"]["screenWidth"]), "%d 原版分屏宽度错误" % number)
		var actor: = await _boss(level, 3357)
		for id in level._active_points:
			level._point_states[id]["spawned"] = level._point_states[id]["target"]
			level._point_states[id]["instances"] = []

		actor.global_position.x = level._battle_bounds.end.x + 400
		actor._physics_process(0)
		_check(actor.global_position.x < level._battle_bounds.end.x, "%d 怪物脱离本波可达区域" % number)
		if number == 77:
			actor.global_position = Vector2(90, 1006)
			level.Role_.position = Vector2(1120, 960)
			_check(level.my_camera.position_smoothing_enabled and level.my_camera.limit_smoothed, "未央宫镜头平滑配置未启用")
			level.Role_.position.x = 100
			level._update_screen_bounds()
			await get_tree().create_timer(1.0).timeout
			await RenderingServer.frame_post_draw
			_check(_visible_rect(level).has_point(actor.global_position - Vector2(0, 40)), "左侧遗留怪物无法进入视角")
			get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_camera_original_left.png")
			var before: Vector2 = level.my_camera.get_screen_center_position()
			actor.queue_free()
			await get_tree().process_frame
			level._update_screen_bounds()
			_check(level.my_camera.get_screen_center_position().distance_to(before) < 20, "清怪瞬间镜头跳动")
			level._activate_trigger(1)
			level.Role_.position = Vector2(1800, 520)
			var prior: = level._camera_left_limit
			for i in range(240):
				level._update_screen_bounds(1.0 / 60)
				_check(absf(level._camera_left_limit - prior) <= 10.01, "下一波限位超过未央宫600px/s")
				prior = level._camera_left_limit
			await get_tree().create_timer(2.0).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_camera_original_next.png")
			print("NORTH_WEIYANG_NEXT ", _visible_rect(level), " limits=", level.my_camera.max_left, ",", level.my_camera.max_right)
			_check(_visible_rect(level).position.x > 990, "未平滑移动到第二波原版1000起点")
		await _dispose(level)
	PlayerData.player_data = old_data
	print("NORTH_CAMERA_PROBE ", _checks, " checks failures=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
