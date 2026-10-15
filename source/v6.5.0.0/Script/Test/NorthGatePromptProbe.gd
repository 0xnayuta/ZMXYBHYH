extends "res://Script/Test/NorthMechanicsProbe.gd"

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var level: = await _level(80)
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	var terrain: = level.get_node("OriginalTerrain")
	for portal: Area2D in terrain._portals:
		var prompt: = portal.get_node("ExitPrompt") as AnimatedSprite2D
		_check(prompt.sprite_frames == level.exit.sprite_frames and prompt.animation == level.exit.animation, 
			"迷宫门没有复用结算出口动画")
		_check(prompt.is_playing() and prompt.scale == level.exit.scale, "出口提示未播放或大小不同")
	level._update_stage_progression()
	for wave in range(1, 4):
		for actor in level.monster.get_children(): actor.queue_free()
		await get_tree().process_frame
		for id in level._active_points:
			level._point_states[id]["spawned"] = level._point_states[id]["target"]
			level._point_states[id]["instances"] = []
		if wave < 3:
			level._update_stage_progression()
	await get_tree().physics_frame
	await get_tree().physics_frame
	for portal: Area2D in terrain._portals:
		_check(portal.visible, "三波清完门提示未显示")
	level.Role_.position = Vector2(289, 440)
	await get_tree().create_timer(0.2).timeout
	_check(level.maze_room == 1, "同款出口特效触碰后自动换房")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_gate_exit_prompt.png")
	Input.action_press("Exit")
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_release("Exit")
	_check(level.maze_room == 7, "按W没有进入百眼魔君房间")
	await _dispose(level)
	PlayerData.player_data = old_data
	print("NORTH_GATE_PROMPT_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
