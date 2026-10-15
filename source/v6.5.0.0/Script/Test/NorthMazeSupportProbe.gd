extends "res://Script/Test/NorthMechanicsProbe.gd"

func _clear_room(level: NorthContinentLevel) -> void :
	for enemy in level.monster.get_children(): enemy.queue_free()
	for id in level._active_points:
		level._point_states[id]["spawned"] = level._point_states[id]["target"]
		level._point_states[id]["instances"] = []
	await get_tree().process_frame

func _run() -> void :
	Global.cd_path = ""
	Global.Is_Show = true
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["CurrentLevelPage"] = 8
	MainSet.set_data["CreateMonsterCount"] = 1
	RoleProp.set_physics_process(false)
	var old_data: = PlayerData.player_data.duplicate(true)
	PlayerData.player_data["头衔"] = []
	var level: = await _level(80)
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	level._update_stage_progression()
	for wave in range(1, 4):
		_check(level.current_stage == wave, "幻境阁波次顺序错误")
		_check( not level.maze_choices_ready(), "当前波未清完就显示分支门")
		await _clear_room(level)
		if wave < 3:
			level._update_stage_progression()
	_check(level.maze_choices_ready(), "三波清完未开放分支")
	level.enter_maze_gate(0)
	level._update_stage_progression()
	_check(level.maze_room == 7 and level.current_stage == 7 and level._active_points.has(70), "左门未进入百眼魔君波次")
	await _dispose(level)
	level = await _level(77)
	level.set_physics_process(false)
	level.Role_.set_physics_process(false)
	for enemy in level.monster.get_children(): enemy.queue_free()
	await get_tree().process_frame
	var mage: = await _boss(level, 3367)
	var ally: = await _boss(level, 3357)
	mage.cast_action(_action(mage, "attack1"))
	_check(ally.is_control_immune() and mage.is_control_immune(), "雪法师未给友方和自身霸体")
	_check(ally._apply_role_damage_vs_reduction(3000) == 2001, "雪法师没有33.3%实际减伤")
	_check( not _shots_for("attack1_1").is_empty(), "雪法师友方加持特效缺失")
	var visual_count: = _shots_for("attack1_1").size()
	mage.cast_action(_action(mage, "attack1"))
	_check(_shots_for("attack1_1").size() == visual_count, "重复加持堆积特效")
	var guard: = _shots_for("attack1_1")[-1]["projectile"] as WutaiMinghaiProjectile
	var owner: BaseMonster = guard.owner_monster
	owner.global_position += Vector2(80, 0)
	await get_tree().create_timer(0.1).timeout
	_check(guard.global_position.distance_to(owner.global_position) < 2, "加持特效不跟随受益怪物")
	await get_tree().create_timer(5.1).timeout
	_check( not ally.is_control_immune() and ally._apply_role_damage_vs_reduction(3000) == 3000, "加持到期未恢复")
	mage.queue_free()
	ally.queue_free()
	await get_tree().process_frame
	var stalker: = await _boss(level, 3400)
	var hero: = level.Role_ as BaseHero
	hero.position = Vector2(600, 940)
	RoleProp.SourcePlayer = hero
	hero.needProtect = false
	var hits: = [0]
	stalker.source_projectile_spawned.connect( func(_sequence, projectile):
		projectile.hit_callback = func(_shot, _target): hits[0] += 1)
	for facing in [-1.0, 1.0]:
		hero.action.scale.x = facing
		stalker.position = Vector2(850, 940)
		stalker.cast_action(_action(stalker, "attack1"))
		await get_tree().create_timer(0.82).timeout
		var collider: = hero.get_node("pz") as CollisionShape2D
		_check(is_equal_approx(stalker.global_position.x, hero.global_position.x + facing * 50), "追魄使者没有瞬移到目标背后侧面")
		_check(is_equal_approx(stalker.global_position.y, collider.global_position.y + collider.shape.get_rect().end.y - 60), "瞬移没有按人物脚底注册点定位")
		await get_tree().create_timer(0.45).timeout
	_check(hits[0] > 0, "追魄使者攻击实际命中失败")
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/north_stalker_fixed.png")
	await _dispose(level)
	PlayerData.player_data = old_data
	print("NORTH_MAZE_SUPPORT_CHECKS=", _checks, " FAILURES=", _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)
