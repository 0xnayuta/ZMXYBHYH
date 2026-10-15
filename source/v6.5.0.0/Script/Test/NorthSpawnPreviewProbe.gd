extends "res://Script/Test/NorthMechanicsProbe.gd"

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	var old_settings: = MainSet.set_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	for multiplier in [1, 4]:
		MainSet.set_data["CreateMonsterCount"] = multiplier
		var level: = await _level(77)
		level.set_physics_process(false)
		level.Role_.set_physics_process(false)
		level._active_points.clear()
		level._initialize_point_states()
		var tested: Dictionary = {}
		for point: Dictionary in level._birth_points():
			var is_boss: bool = NorthOriginalData.monster_record(int(point["monster"])).get("boss", "0") == "1"
			var expected: int = int(point["total"]) * (1 if is_boss else multiplier)
			_check(int(level._point_states[int(point["point"])]["target"]) == expected, "刷怪点数量倍数错误")
			if not is_boss and tested.is_empty() and int(point["total"]) > 1 and int(point["after_dead"]) == 0 and int(point["after_spawn"]) == 0:
				tested = point
		_check( not tested.is_empty(), "没有找到实际生成测试点")
		level._active_points[int(tested["point"])] = true
		level._ready_triggers[int(tested["stage"])] = true
		var state: Dictionary = level._point_states[int(tested["point"])]
		for index in range(int(state["target"])):
			level._elapsed = 1000 + index * 2
			level._spawn_next_protected_unit()
			await get_tree().process_frame
			for actor in state["instances"]:
				actor.set_physics_process(false)
		_check(int(state["spawned"]) == int(tested["total"]) * multiplier, "实际生成数量没有倍增")
		for interval in [1.2, 0.075]:
			MainSet.set_data["CreateMonsterSpeed"] = interval
			state["spawned"] = 0
			state["next_spawn_at"] = 0
			level._elapsed = 5000
			level._spawn_next_protected_unit()
			var wait_time: float = float(tested["tile"]["birthInterval"]) * interval / 1.2
			_check(is_equal_approx(float(state["next_spawn_at"]), 5000 + wait_time), "原版刷怪间隔未按速度缩短")
			var before: = int(state["spawned"])
			level._elapsed += wait_time * 0.5
			level._spawn_next_protected_unit()
			_check(int(state["spawned"]) == before, "生成间隔提前")
			level._elapsed = 5000 + wait_time + 0.001
			level._spawn_next_protected_unit()
			_check(int(state["spawned"]) == before + 1, "生成速度未影响实际刷怪")
			await get_tree().process_frame
			for actor in state["instances"]: actor.set_physics_process(false)
		await _dispose(level)
	for number in [80, 85]:
		var level: = await _level(number)
		level.set_physics_process(false)
		level.Role_.set_physics_process(false)
		var center: Vector2 = level.my_camera.global_position
		for pos in [Vector2(50, 80), Vector2(900, 500), Vector2(400, 200)]:
			level.Role_.position = pos
			for index in range(120): level._update_screen_bounds(1.0 / 60)
			_check(level.my_camera.global_position.is_equal_approx(center), "单房间镜头随角色移动")
		_check(level.my_camera.zoom == Vector2.ONE, "固定镜头放大了画面")
		await _dispose(level)
	var canvas: = CanvasLayer.new()
	add_child(canvas)
	var ids: Dictionary = {}
	var screenshot_heads: Array = []
	for number in range(76, 86):
		for entry: Dictionary in NorthOriginalData.preview(number)["MonsterList"]:
			var id: = int(entry["ConfigId"])
			if ids.has(id): continue
			ids[id] = true
			var head: = Global.AddMonsterHead(canvas, entry["Name"], entry["IsBoss"], entry["ScenePath"]) as Control
			await get_tree().physics_frame
			await get_tree().physics_frame
			var preview: = head.get_node_or_null("IdlePreview") as AnimatedSprite2D
			_check(preview != null, "待机图缺失：%d" % id)
			if preview != null:
				_check(preview.is_playing() and preview.sprite_frames.get_frame_count(&"wait") > 0, "待机动画未播放")
			if screenshot_heads.size() < 12:
				head.position = Vector2(30 + screenshot_heads.size() % 6 * 150, 30 + screenshot_heads.size() / 6 * 150)
				screenshot_heads.append(head)
			else:
				head.queue_free()
	if not screenshot_heads.is_empty():
		var preview: = screenshot_heads[0].get_node("IdlePreview") as AnimatedSprite2D
		var frame_before: = preview.frame
		await get_tree().create_timer(0.15).timeout
		_check(preview.frame != frame_before, "待机预览没有推进帧")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_idle_previews.png")
	canvas.queue_free()
	PlayerData.player_data = old_data
	MainSet.set_data = old_settings
	print("NORTH_SPAWN_PREVIEW_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
