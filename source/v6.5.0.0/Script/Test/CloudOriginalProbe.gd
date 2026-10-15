extends Node

var _failures: Array[String] = []
var _checks: = 0
var _shots: Array[Dictionary] = []

func _ready() -> void :
	call_deferred("_run")
	get_tree().create_timer(80.0).timeout.connect( func(): get_tree().quit(2))

func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("CLOUD_FAIL " + message)

func _run() -> void :
	get_tree().current_scene = null
	MainSet.set_auto_battle_enabled(false)
	MainSet.set_data["Difficult"] = 0
	Global.Is_Show = true
	Global.cd_path = ""
	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	var level: = load("res://Scene/Level/Level_75.tscn").instantiate() as Level75
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	await get_tree().create_timer(1.0).timeout
	var hero: BaseHero = level.Role_
	var terrain: = level.get_node("OriginalTerrain")
	hero.SXYRCannotCure = true
	hero.needProtect = true
	hero.set_meta("pet_turtle_link_unit_ref", false)
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Hp = 10000000
	_check(hero.is_on_floor(), "原版出生位置没有落在第一片云上")
	_check(level.current_stage == 0 and level.monster.get_child_count() == 0, "未经过原版触发区就刷新教主")
	_check(level.get_node("wall/floor").disabled, "占位平路未关闭")
	_check(level.hero.position == Vector2.ZERO and level.monster.position == Vector2.ZERO, "场景父节点坐标错误")
	_check(terrain.screen_templates.size() == 6 and terrain.screen_templates[0] == 1 and terrain.screen_templates[-1] == 6, 
		"缩短路线缺少起终点")
	var templates: Array = terrain.screen_templates.slice(1, 5)
	templates.sort()
	_check(templates == [2, 3, 4, 5], "缩短路线缺少中段机关模板")
	_check(level.level_width_override == 6800 and level.my_camera.max_right == 6800, "云川长度/镜头没有缩到三分之一")
	_check(level.exit.position == Vector2(6589, 315), "出口没有移到缩短路线末端")
	_check(level.check_can_exit(), "追逐关仍要求击杀教主才开放出口")
	_check(level._screen_right_wall.disabled, "追逐路线被刷怪边界阻断")
	await _capture("cloud_start")
	var start_x: = hero.position.x
	Input.action_press("move_right")
	hero.jump()
	await get_tree().create_timer(0.45).timeout
	hero.jump()
	await get_tree().create_timer(0.85).timeout
	Input.action_release("move_right")
	_check(hero.position.x > start_x + 200 and not hero.IsDeath, "实际二段跳没有横跨云台")
	hero.position = Vector2(435, 430)
	hero.velocity = Vector2.ZERO
	await get_tree().create_timer(1.1).timeout
	_check(hero.is_on_floor(), "第二片云台没有碰撞")
	var boss: BaseMonster = null
	for enemy in level.monster.get_children():
		if enemy is BaseMonster:
			boss = enemy
	_check(boss != null, "经过触发区没有刷出通天教主")
	if boss == null:
		get_tree().quit(1)
		return
	level.create_control.stop()
	boss.is_attacking = true
	boss.Hp = boss.SHp - 100000
	await get_tree().create_timer(1.1).timeout
	_check(boss.Hp == boss.SHp, "教主没有原版每秒回血")
	boss.is_attacking = false
	boss.set_physics_process(false)
	boss.global_position = Vector2(760, 330)
	boss._flight_y = 330.0
	_check(boss.SHp in [4389508, 4389509] and boss.attack_in == 2899 and boss.def == 333 and boss.mdef == 14, "教主属性不符源配置")
	_check(boss._config["level"] == 56 and boss.fall_list.is_empty(), "等级或装备掉落不符原版")
	boss.skill_projectile_spawned.connect( func(sequence, projectile):
		_shots.append({"sequence": sequence, "projectile": projectile, "time": Time.get_ticks_msec(), "position": projectile.spawn_global_position}))
	hero.set_physics_process(false)
	for action in [&"hit1", &"hit2", &"hit3"]:
		boss.is_attacking = false
		boss._dash_active = false
		boss._skill_cursor = int(str(action).right(1)) - 1
		boss.global_position = Vector2(760, 330)
		_shots.clear()
		var cast_time: = Time.get_ticks_msec()
		boss.attack_target()
		await get_tree().create_timer(0.75).timeout
		_check( not _shots.is_empty(), "%s 没有原版特效" % action)
		for shot: Dictionary in _shots:
			var projectile: WutaiMinghaiProjectile = shot["projectile"]
			if is_instance_valid(projectile):
				_check( not projectile.track_target, "原版直线弹丸被改成持续追踪")
				_check( not projectile.source_masks.is_empty(), "技能没有使用原版 ab 判定")
		await _capture("cloud_%s" % str(action))
		if action == &"hit1":
			_check(boss._dash_active, "冲撞期间没有无敌")
			var hp: = boss.Hp
			boss.reduce_hp(10000)
			_check(boss.Hp == hp, "冲撞仍能受伤")
			var prior: = boss.global_position
			await get_tree().create_timer(1.0).timeout
			_check( not boss._dash_active and boss.global_position.distance_to(prior) > 10.0, "冲撞结束没有原版位移和恢复")
		elif action == &"hit2":
			await get_tree().create_timer(0.7).timeout
			_check(_shots.size() == 3 and _shots[1]["sequence"] == "effect2_2" and _shots[2]["sequence"] == "effect2_2", "雷电风暴缺少两次侧边攻击")
			_check(absf(float(_shots[1]["position"].x) - hero.global_position.x + 200) < 1.0
				and absf(float(_shots[2]["position"].x) - hero.global_position.x - 200) < 1.0, "雷电风暴位置不是人物左右 200")
		else:
			await get_tree().create_timer(1.6).timeout
			_check(_shots.size() == 3, "混沌弹丸未发射三次")
			if _shots.size() == 3:
				_check(absi(int(_shots[0]["time"]) - cast_time - 462) < 120, "第一发弹丸时刻错误")
				_check(absi(int(_shots[2]["time"]) - cast_time - 2244) < 160, "第三发弹丸时刻错误")
		boss._attack_serial += 1
		boss.mr_player.play(&"wait")
		for projectile in boss.bullet.get_children():
			projectile.queue_free()
	boss.queue_free()
	hero.set_physics_process(true)
	var moving: Dictionary = terrain._moving[0]
	var body: AnimatableBody2D = moving["body"]
	var source_position: = body.position
	await get_tree().create_timer(0.3).timeout
	_check(body.position.distance_to(source_position) > 10.0, "移动云没有移动")
	var moving_shape: = body.get_child(0) as CollisionShape2D
	var cloud_top: float = moving_shape.position.y - moving_shape.shape.size.y * 0.5
	hero.position = Vector2(body.position.x + moving_shape.position.x, body.position.y + cloud_top - 120)
	hero.velocity = Vector2.ZERO
	await get_tree().create_timer(0.75).timeout
	_check(hero.is_on_floor(), "人物无法落在移动云上")
	await _capture("cloud_moving")
	var cloud: Dictionary = terrain._collapsing[0]
	var rect: Rect2 = cloud["rect"]
	hero.position = Vector2(rect.get_center().x, rect.position.y - 120)
	hero.velocity = Vector2.ZERO
	await get_tree().create_timer(0.75).timeout
	_check(hero.is_on_floor() and float(cloud["collapse_at"]) >= 0, "踩踏塌陷云没有开始计时")
	await _capture("cloud_collapse")
	hero.set_physics_process(false)
	await get_tree().create_timer(float(cloud["die_delay"]) + 0.15).timeout
	_check(cloud["shape"].disabled and cloud["sprite"].animation == &"dead", "塌陷时云台仍有碰撞")
	hero.position = Vector2(120, 293)
	await get_tree().create_timer(3.15).timeout
	_check( not cloud["shape"].disabled and cloud["sprite"].animation == &"default", "塌陷云没有按原版 3 秒恢复")
	var hazard: Dictionary = terrain._hazards[0]
	var data: Dictionary = hazard["data"]
	var hits: Array = data["hits"]
	var hit: Array = hits.filter( func(h): return not h.is_empty())[0]
	hero.global_position = terrain.global_position + (hazard["origin"] as Vector2) + Vector2(float(hit[0]) + float(hit[2]) / 2.0, float(hit[1]) + float(hit[3]) / 2.0)
	hero.needProtect = false
	var hp_before: = int(RoleProp.roleprop.Hp)
	await get_tree().create_timer(1.8).timeout
	_check(int(RoleProp.roleprop.Hp) < hp_before, "雷电云原版判定没有伤害")
	hero.needProtect = true
	hero.position = Vector2(6440, 250)
	hero.velocity = Vector2.ZERO
	hero.set_physics_process(true)
	await get_tree().create_timer(0.7).timeout
	_check(hero.is_on_floor(), "末屏地形不能落脚")
	await _capture("cloud_end")
	hero.set_physics_process(false)
	hero.position = Vector2(120, 630)
	RoleProp.roleprop.Hp = 10000000
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, true)
	await get_tree().create_timer(0.2).timeout
	_check(int(RoleProp.roleprop.Hp) == 0, "落入原版死亡线仍能被免伤阻止")
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, false)

	level.queue_free()
	get_tree().current_scene = null
	await get_tree().process_frame
	var old_progress: Variant = PlayerData.player_data.get("东胜神州通关_75", null)
	var old_cloud: Variant = PlayerData.player_data.get("云川", null)
	PlayerData.player_data.erase("东胜神州通关_75")
	PlayerData.player_data.erase("云川")
	level = load("res://Scene/Level/Level_75.tscn").instantiate() as Level75
	get_tree().root.add_child(level)
	get_tree().current_scene = level
	await get_tree().create_timer(0.75).timeout
	hero = level.Role_
	hero.needProtect = true
	RoleProp.roleprop.Hp = 10000000
	hero.position = Vector2(6440, 250)
	hero.velocity = Vector2.ZERO
	await get_tree().create_timer(0.6).timeout
	Input.action_press("move_right")
	var seconds: = 0.0
	while get_tree().current_scene == level and not level.can_exit and seconds < 3.0:
		await get_tree().create_timer(0.1).timeout
		seconds += 0.1
	Input.action_release("move_right")
	_check(get_tree().current_scene == level and level.can_exit, "云川出口未按W就结算或未检测到人物")
	Input.action_press("Exit")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("Exit")
	await get_tree().create_timer(1.0).timeout
	_check(get_tree().current_scene != null and get_tree().current_scene.scene_file_path == "res://Scene/Level/victory.tscn", 
		"云川出口按W没有通关")
	_check(bool(PlayerData.player_data.get("东胜神州通关_75", false)) and int(PlayerData.player_data.get("云川", 0)) == 1, 
		"云川通关没有写入兼容进度")
	for key: String in ["东胜神州通关_75", "云川"]:
		var old: Variant = old_progress if key == "东胜神州通关_75" else old_cloud
		if old == null:
			PlayerData.player_data.erase(key)
		else:
			PlayerData.player_data[key] = old
	print("CLOUD_ORIGINAL_PROBE %s checks=%d failures=%d" % ["OK" if _failures.is_empty() else "FAIL", _checks, _failures.size()])
	get_tree().quit(0 if _failures.is_empty() else 1)

func _capture(filename: String) -> void :
	await get_tree().create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.codex_tmp/%s.png" % filename)
