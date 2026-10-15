extends Node









const BOSS_CASES: = [
	["res://Scene/Monster/Monster_13101.tscn", 31], 
	["res://Scene/Monster/Monster_13401.tscn", 34], 
	["res://Scene/Monster/Monster_19201.tscn", 192], 
]

var _failures: Array[String] = []
var _checks: = 0


func _ready() -> void :
	Engine.time_scale = 6.0
	get_tree().create_timer(420.0, false).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void :
	Engine.time_scale = 1.0
	print("LIUSHA_BOSS_BATTLE_TIMEOUT")
	get_tree().quit(2)


func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("BATTLE_FAIL: " + message)


func _run() -> void :
	MainSet.set_data["NoShowMonsterBody"] = true
	MainSet.set_data["MonsterBloodSHow"] = false
	var previous_role_position: Variant = RoleProp.role_pos

	var arena: = Node2D.new()
	add_child(arena)
	var floor_body: = StaticBody2D.new()
	var floor_shape: = CollisionShape2D.new()
	var rect: = RectangleShape2D.new()
	rect.size = Vector2(4000, 40)
	floor_shape.shape = rect
	floor_shape.position = Vector2(600, 420)
	floor_body.add_child(floor_shape)
	arena.add_child(floor_body)

	for case_data in BOSS_CASES:
		RoleProp.role_pos = Vector2(320, 380)
		var scene: = load(str(case_data[0])) as PackedScene
		var boss: = scene.instantiate() as LiuShaRiverBoss
		arena.add_child(boss)
		boss.global_position = Vector2(560, 380)
		await get_tree().physics_frame
		await get_tree().physics_frame
		boss.monster_dir.scale.x = -1
		await get_tree().physics_frame

		await _run_all_skills(boss)
		await _check_gxp(boss)
		await _check_shadow(boss)
		await _check_behavior_fixes(boss)
		if boss.boss_kind == 31:
			await _check_tang_teleport(boss)
			await _check_tang_heal(boss)


		boss.attack_target()
		await get_tree().physics_frame
		boss.queue_free()
		await get_tree().physics_frame

	RoleProp.role_pos = previous_role_position
	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("LIUSHA_BOSS_BATTLE_OK (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		print("LIUSHA_BOSS_BATTLE_FAILED: %d" % _failures.size())
		for failure in _failures:
			print("  - " + failure)
		get_tree().quit(1)



func _run_all_skills(boss: LiuShaRiverBoss) -> void :
	var actions: Dictionary = LiuShaRiverBoss.ACTIONS[boss.boss_kind]
	for action_value in actions:
		var action: = str(action_value)
		if not action.begins_with("hit"):
			continue

		if action in ["hit4_2", "hit11_1", "hit11_2"]:
			continue
		boss._use_skill(action, 1)
		var guard: = 0
		while boss._skill_busy and guard < 600:
			await get_tree().physics_frame
			guard += 1
		if guard >= 600:
			_check(false, "%s 技能 %s 卡死" % [boss.my_mr_name, action])
		else:
			_check(true, "%s 技能 %s 正常结束" % [boss.my_mr_name, action])



	if boss.boss_kind == 31:
		boss._use_skill("hit4_1", 1)
		await get_tree().physics_frame
		var upward_seen: = false
		for _i in range(20):
			if boss._active_skill == "hit4_1" and boss.is_attacking:
				boss._tick_skill_motion(1.0 / 60.0)
				if boss.velocity.y < -1.0:
					upward_seen = true
			await get_tree().physics_frame
		_check(upward_seen, "邪·唐僧 hit4_1 没有产生向上位移")
		var wait_guard: = 0
		while boss._skill_busy and wait_guard < 600:
			await get_tree().physics_frame
			wait_guard += 1



	if boss.boss_kind == 34:
		boss._active_skill = "hit7"
		boss.is_attacking = true
		boss._skill_time = 0.0
		boss._tick_skill_motion(0.0)
		var early_speed: = absf(boss.velocity.x)
		boss._skill_time = 0.6
		boss._tick_skill_motion(0.0)
		var late_speed: = absf(boss.velocity.x)
		boss._active_skill = ""
		boss.is_attacking = false
		boss.velocity.x = 0.0
		_check(early_speed > 0.0, "邪·悟空 hit7 起手没有冲刺速度")
		_check(
			early_speed > late_speed, 
			"邪·悟空 hit7 冲刺应为衰减（起手 %.1f 未大于尾声 %.1f）" % [early_speed, late_speed]
		)



func _check_gxp(boss: LiuShaRiverBoss) -> void :
	if boss.boss_kind == 192:
		boss._enter_gxp()
		_check( not boss._gxp_active, "邪·后羿不应进入师徒狂暴状态")
		_check(boss.speed == 12, "邪·后羿速度不应受狂暴影响")
		return

	if boss._gxp_active:
		boss._exit_gxp()
	boss._gxp_timer = 0.0
	await get_tree().physics_frame
	var base_speed: int = int(boss.speed)
	var base_super: bool = bool(boss.IsSuperArmor)
	boss._enter_gxp()
	await get_tree().physics_frame
	_check(boss._gxp_active, "%s GXP 未激活" % boss.my_mr_name)
	_check(boss.IsSuperArmor, "%s GXP 未获得霸体" % boss.my_mr_name)
	_check(boss.speed > base_speed, "%s GXP 未提升速度" % boss.my_mr_name)
	boss._enter_gxp()
	_check(boss.speed == int(round(base_speed * 1.5)), "%s GXP 重入重复叠加速度" % boss.my_mr_name)
	boss._gxp_timer = 20.0
	var before_afterimages: = boss.get_parent().get_child_count()
	boss._tick_gxp(0.2)
	_check(boss.get_parent().get_child_count() > before_afterimages, "%s 周期计时期间未产生狂暴残影" % boss.my_mr_name)

	for _i in range(6):
		await get_tree().physics_frame
	boss._exit_gxp()
	await get_tree().physics_frame
	_check( not boss._gxp_active, "%s GXP 未退出" % boss.my_mr_name)
	_check(boss.IsSuperArmor == base_super, "%s GXP 退出后霸体未恢复" % boss.my_mr_name)
	_check(boss.speed == base_speed, "%s GXP 退出后速度未恢复" % boss.my_mr_name)



func _check_shadow(boss: LiuShaRiverBoss) -> void :
	if boss.boss_kind == 192:

		var before: = boss.get_child_count()
		boss._spawn_shadow(boss.global_position + Vector2(-105, 0))
		await get_tree().physics_frame
		_check(boss._shadows.is_empty(), "邪·后羿不应生成分身")
		_check(boss.get_child_count() == before, "邪·后羿分身调用产生了额外节点")
		return

	for old_shadow in boss._shadows:
		if is_instance_valid(old_shadow):
			old_shadow.queue_free()
	boss._shadows.clear()
	await get_tree().physics_frame
	var before_count: = boss.get_child_count()
	boss._spawn_shadow(boss.global_position + Vector2(-105, 0))
	await get_tree().physics_frame
	_check(boss._shadows.size() == 1, "%s 分身未生成" % boss.my_mr_name)
	if boss._shadows.is_empty():
		return
	var shadow = boss._shadows[0]
	_check(is_instance_valid(shadow) and shadow.is_inside_tree(), "%s 分身无效" % boss.my_mr_name)
	_check(shadow.boss_kind == boss.boss_kind, "%s 分身种类错误" % boss.my_mr_name)


	var before_attack_count: = boss.get_child_count()
	boss._command_shadow("hit1")
	var attack_spawned: = false
	for _i in range(240):
		await get_tree().physics_frame
		if boss.get_child_count() > before_attack_count:
			attack_spawned = true
			break
	_check(attack_spawned, "%s 分身出招未回调攻击特效" % boss.my_mr_name)



	await get_tree().create_timer(2.3, false).timeout
	_check( not is_instance_valid(shadow), "%s 分身出招结束后未销毁" % boss.my_mr_name)


func _check_behavior_fixes(boss: LiuShaRiverBoss) -> void :
	boss.set_physics_process(false)
	boss._skill_busy = false
	boss.is_attacking = false
	boss._active_skill = ""
	boss.global_position = Vector2(560, 400)
	RoleProp.role_pos = Vector2(320, 400)
	if boss.boss_kind == 31:
		boss._execute_tang_event("hit4_2")
		var pillar: = boss.get_children().back() as Node2D
		_check(is_equal_approx(pillar.global_position.y + 395.0, 400.0), "水柱底部未对齐地面")
		var ground_anchor: = pillar.global_position.y
		boss.global_position.y -= 160.0
		boss._execute_tang_event("hit4_2")
		var second: = boss.get_children().back() as Node2D
		_check(is_equal_approx(second.global_position.y, ground_anchor), "唐僧浮空改变了水柱高度")
		var shape: = second.get_node("BaseDamageBox/HitBox/HitBox") as CollisionShape2D
		_check(is_equal_approx((shape.shape as RectangleShape2D).size.y, 431.0), "水柱判定高度仍被裁短")
	elif boss.boss_kind == 34:
		boss._update_shadows(0.0)
		boss._skill1_cd = 999.0
		RoleProp.role_pos = boss.global_position + Vector2(-400, 0)
		boss.Monster_Intelligence()
		_check(boss.velocity.x < 0.0 and not boss.is_attacking, "悟空在攻击范围外未追击")
		for _i in range(80):
			var skill: = boss._pick_skill(1, 400.0)
			_check(skill == "" or float(LiuShaRiverBoss.MONKEY_SKILL_REACH[skill]) >= 400.0, "悟空选择了无法触及目标的技能")
		boss._use_skill("hit11_1", 1)
		_check( not boss._skill_busy, "已移除的筋斗云仍能启动")
		boss._active_skill = "hit9"
		boss.is_attacking = true
		boss._execute_monkey_event("hit9")
		var flame: = boss.get_children().back() as Node2D
		_check( not boss.mr_ani.visible, "烈焰闪未隐藏本体")
		var start: = flame.global_position
		boss.global_position += Vector2(-90, -15)
		_check(flame.global_position.is_equal_approx(start + Vector2(-90, -15)), "烈焰闪特效和判定未跟随本体")
		boss.is_attacking = false
		boss._active_skill = ""
		boss._physics_process(0.0)
		_check(boss.mr_ani.visible, "烈焰闪结束未恢复本体")
	boss.global_position = Vector2(560, 400)
	boss._active_skill = ""
	boss.is_attacking = false
	boss.set_physics_process(true)


func _check_tang_teleport(boss: LiuShaRiverBoss) -> void :
	for shadow in boss._shadows:
		if is_instance_valid(shadow):
			shadow.queue_free()
	boss._shadows.clear()
	boss._skill_busy = false
	boss.is_attacking = false
	boss._use_skill("hit10", 1)
	_check(boss._shadows.size() == 1, "邪·唐僧即时 hit10 未召唤分身")
	_check( not boss._skill_busy, "邪·唐僧即时 hit10 不应等待动画结束")
	_check(is_equal_approx(boss._skill1_cd, 1.0), "邪·唐僧瞬移冷却应为 1 秒")
	if boss._shadows.is_empty():
		return
	var destination: Vector2 = boss._shadows[0].global_position
	boss.global_position.x += 200
	boss._use_skill("hit10", 1)
	_check(boss.global_position.is_equal_approx(destination), "邪·唐僧未回到分身位置")
	_check(boss._shadows.is_empty(), "邪·唐僧瞬移后未清理分身")
	boss._start_skill_cooldown(1, "hit5")
	_check(is_equal_approx(boss._skill1_cd, 4.0), "邪·唐僧普通技能冷却应为 4 秒")


func _check_tang_heal(boss: LiuShaRiverBoss) -> void :
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	boss.Hp = boss.SHp - 20000
	RoleProp.role_pos = boss.global_position + Vector2(2000, 0)
	var hp_before: = boss.Hp
	boss._tang_heal_resolve(boss.global_position + Vector2(0, -60), 0)
	_check(boss.Hp > hp_before, "邪·唐僧回血应检测 Boss 与特效距离，不依赖玩家靠近")
	var before: = boss.get_child_count()
	boss._execute_attack_event("hit6")
	_check(boss.get_child_count() > before, "邪·唐僧持续回血没有技能特效")
	for child in boss.get_children():
		if child.name == "LiuShaVisual_Role2Bullet6":
			_check(child.get_node_or_null("BaseDamageBox") == null, "邪·唐僧回血特效不应产生伤害判定")
	boss.process_mode = Node.PROCESS_MODE_INHERIT
