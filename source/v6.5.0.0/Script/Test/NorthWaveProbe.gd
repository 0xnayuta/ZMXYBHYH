extends "res://Script/Test/NorthMechanicsProbe.gd"

func _clear_points(level: NorthContinentLevel) -> void :
	for id in level._active_points:
		level._point_states[id]["spawned"] = level._point_states[id]["target"]
		level._point_states[id]["instances"] = []

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	for number in [76, 77, 85]:
		var level: = await _level(number)
		level.set_physics_process(false)
		level.Role_.set_physics_process(false)
		for enemy in level.monster.get_children(): enemy.queue_free()
		await get_tree().process_frame
		level._active_points.clear()
		level._visited_triggers.clear()
		level._pending_triggers.clear()
		level._ready_triggers.clear()
		level._initialize_point_states()
		var first: = 1 if number in [76, 85] else 0
		var second: = 2 if number == 76 else (0 if number == 85 else 1)
		level._activate_trigger(first)
		var actor: = await _boss(level, 3357)
		_clear_points(level)
		level._update_screen_bounds()
		var locked_right: float = level.my_camera.max_right
		var locked_top: float = level.my_camera.max_top
		var locked_left: float = level.my_camera.max_left
		level.Role_.position = Vector2(locked_right + 200, locked_top - 200)
		level._update_screen_bounds()
		_check((number == 77 and not level._screen_right_wall.disabled) or level.Role_.position.x <= locked_right - 25 and (number != 76 or level.Role_.position.y >= locked_top + 40), 
			"%d 当前波未清完就能越出战斗视角" % number)
		_check(level.my_camera.max_right == locked_right and level.my_camera.max_left == locked_left, 
			"%d 当前波未清完镜头范围跟随人物改变" % number)
		if number == 77:
			level.Role_.position = Vector2(locked_right - 30, 960)
			level.Role_.set_physics_process(true)
			level.set_physics_process(true)
			Input.action_press("move_right")
			await get_tree().create_timer(0.5).timeout
			Input.action_release("move_right")
			_check(level.Role_.position.x <= locked_right - 20, "实际向右输入越过未清怪区域")
			print("NORTH_CAMERA_VIEW ", level.my_camera.get_screen_center_position(), " bounds=", level._battle_bounds, " viewport=", level.get_viewport_rect(), " zoom=", level.my_camera.zoom)
			_check(level.my_camera.get_screen_center_position().x <= locked_right - level.get_viewport_rect().size.x / level.my_camera.zoom.x / 2 + 2, 
				"实际镜头提前进入下一波")
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_camera_locked.png")
			level.set_physics_process(false)
			level.Role_.set_physics_process(false)
		if number != 85:
			level.Role_.position.y = float(level._north_data["height"]) + 200
			level._update_screen_bounds()
			_check(level.Role_.position.y > float(level._north_data["height"]), "%d 视角锁定阻止坠落死亡" % number)
		var box: Array = level._north_data["triggers"][second]["rect"]
		level._elapsed = 250
		level.Role_.position = Vector2(float(box[0]) + float(box[2]) / 2, float(box[1]) + float(box[3]) / 2)
		level._update_stage_progression()
		_check( not level._visited_triggers.has(second), "%d 尚有怪物就启动下一波" % number)
		_check(level._pending_triggers.has(second), "%d 提前经过的触发区未记录" % number)
		level._boss_seen = true
		_check( not level.check_can_exit(), "%d 尚有普通怪物就允许通关" % number)

		actor.Hp = 0
		actor.queue_free()
		await get_tree().process_frame
		var point_id: int = level._active_points.keys()[0]
		level._point_states[point_id]["spawned"] -= 1
		level.Role_.position = Vector2(-200, -200)
		level._update_stage_progression()
		_check( not level._visited_triggers.has(second), "%d 当前波尚未刷完就推进" % number)
		_clear_points(level)
		level._update_screen_bounds()
		var starts: = NorthOriginalData.numbers(level._north_data["dungeon"]["sceneStart"])
		var next_right: = minf(float(starts[mini(level.current_stage, starts.size() - 1)]) + float(level._north_data["dungeon"]["screenWidth"]), float(level._north_data["width"]))
		_check(level.my_camera.max_top == 0 and (level._screen_right_wall.position.x == next_right + 5 if number == 77 else level.my_camera.max_right == next_right), 
			"%d 清完后没有开放下一波视角" % number)
		level._update_stage_progression()
		_check(level._visited_triggers.has(second), "%d 清完后没有启动已触发的下一波" % number)
		_check(level._visited_triggers.size() == 2, "%d 一次更新启动多波" % number)
		if number == 77:
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_wave_fixed.png")
		await _dispose(level)
	PlayerData.player_data = old_data
	print("NORTH_WAVE_PROBE ", _checks, " checks failures=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
