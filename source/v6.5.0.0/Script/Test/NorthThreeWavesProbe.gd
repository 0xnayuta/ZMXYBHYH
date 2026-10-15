extends "res://Script/Test/NorthMechanicsProbe.gd"

func _three_waves(level: NorthContinentLevel) -> void :
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	for actor in level.monster.get_children(): actor.queue_free()
	await get_tree().process_frame
	level._active_points.clear()
	level._visited_triggers.clear()
	level.current_stage = 0
	level._configure_level_monsters()
	level._apply_monster_count_multiplier()
	level._update_stage_progression()
	var terrain: = level.get_node("OriginalTerrain")
	for wave in range(1, 4):
		_check(level.current_stage == wave, "固定三波顺序错误")
		_check( not level.maze_choices_ready(), "未清完当前波提前开门")
		var expected: = 0
		for point: Dictionary in level._birth_points():
			if int(point["stage"]) == wave: expected += int(point["total"])
		level._ready_triggers[wave] = true
		for attempt in range(expected + 3):
			level._elapsed += 2
			level._spawn_next_protected_unit()
			await get_tree().process_frame
			for actor in level.monster.get_children(): actor.set_physics_process(false)
		var actual: = 0
		for point: Dictionary in level._birth_points():
			if int(point["stage"]) == wave:
				actual += int(level._point_states[int(point["point"])]["spawned"])
		print("NORTH_THREE_WAVE ", wave, " expected=", expected, " spawned=", actual)
		_check(actual == expected, "当前波实际生成数量不完整")
		level._update_stage_progression()
		_check(level.current_stage == wave, "活怪未清完进入下一波")
		await get_tree().physics_frame
		for portal: Area2D in terrain._portals: _check( not portal.visible, "怪未清完分支出口可见")
		level.enter_maze_gate(0)
		_check(level.maze_room == 1, "怪未清完能进入百眼房")
		for actor in level.monster.get_children(): actor.Hp = 0
		level._update_stage_progression()
		_check(level.current_stage == mini(wave + 1, 3), "清完怪未自动开启下一波")
	_check(level.maze_choices_ready(), "三波完成没有开放分支")
	await get_tree().physics_frame
	await get_tree().physics_frame
	for portal: Area2D in terrain._portals:
		_check(portal.visible and portal.get_node("ExitPrompt").is_playing(), "三波结束出口特效缺失")
	for repeat in range(10): level._update_stage_progression()
	_check(level.current_stage == 3 and level._visited_triggers.size() == 3, "额外重复刷怪或开启第四波")

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CreateMonsterCount"] = 1
	var level: = await _level(80)
	await _three_waves(level)
	level.Role_.position = Vector2(289, 440)
	await get_tree().create_timer(0.15).timeout
	_check(level.maze_room == 1, "左门无W自动进入")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_three_wave_exits.png")
	Input.action_press("Exit")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("Exit")
	_check(level.maze_room == 7, "左出口未选择百眼魔君")
	level._update_stage_progression()
	_check(level.current_stage == 7 and level._active_points.has(70), "左出口没有激活Boss波次")
	level._ready_triggers[7] = true
	level._elapsed = 10000
	level._spawn_next_protected_unit()
	await get_tree().process_frame
	var boss: BaseMonster = level._point_states[70]["instances"][0]
	boss.set_physics_process(false)
	_check(boss.monster_kind == 3409, "左出口生成的Boss不是百眼魔君")
	_check( not level.check_can_exit(), "百眼未击杀就能结算")
	boss.Hp = 0
	await get_tree().physics_frame
	_check( not level.check_can_exit(), "Boss掉落未处理就允许结算")
	boss.set_meta("death_drops_settled", true)
	_check(level.check_can_exit(), "百眼击杀后不能结算")
	await _dispose(level)
	level = await _level(80)
	await _three_waves(level)
	level.Role_.position = Vector2(910, 440)
	await get_tree().create_timer(0.15).timeout
	_check(level.maze_room == 1, "右门无W自动进入")
	Input.action_press("Exit")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("Exit")
	await get_tree().create_timer(2).timeout
	var hidden: = get_tree().current_scene as NorthContinentLevel
	_check(hidden != null and hidden.hidden_original_room, "右出口没有实际进入隐藏关")
	if hidden != null:
		_check(hidden.source_map == "huanjinggeyincang", "隐藏关地图错误")
		hidden.create_control.stop()
		hidden.Role_.set_meta("pet_turtle_link_unit_ref", false)
		await _dispose(hidden)
	PlayerData.player_data = old_data
	print("NORTH_THREE_WAVES_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
