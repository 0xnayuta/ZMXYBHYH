extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 4
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能7"]["等级"] = 1
	PlayerData.player_data["技能学习"]["技能10"]["等级"] = 0
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["lhsq"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["lhsq"] = true
	PlayerData.player_data["技能觉醒启用"] = enabled_data

	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _frame in range(24):
		await get_tree().process_frame

	var hero: = level.get("Role_") as role4
	var monster_root: = level.get_node_or_null("Monster")
	var spawn_timer: = level.get_node_or_null("create_control") as Timer
	if spawn_timer != null:
		spawn_timer.stop()
	_check(hero != null and monster_root != null, "灵魂摄取觉醒测试场景初始化失败")
	if hero == null or monster_root == null:
		return

	hero.set_process(false)
	hero.set_physics_process(false)
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame

	var target: = _spawn_target(monster_root, Vector2(760.0, 350.0))
	var target_hurt_box: = target.get_node_or_null("BaseDamageBox/HurtBox") as Area2D
	_check(target_hurt_box != null, "灵魂摄取命中测试缺少敌人受击区域")
	if target_hurt_box == null:
		return

	var awaken_popup: = (load("res://Scene/Skill/SkillAwakenPopup.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(awaken_popup)
	awaken_popup.configure("灵魂摄取", null, "lhsq")
	var description: = str(awaken_popup.get_node("EffectDescription").text)
	_check(description.contains("20%最大生命值和20%攻击") and description.contains("最多叠加五次") and description.contains("持续10秒"), "灵魂摄取觉醒描述不正确")
	_check( not awaken_popup.get_node("AwakenEnabled").disabled, "灵魂摄取觉醒仍处于未开放状态")
	awaken_popup.queue_free()

	RoleProp.get_last_prop()
	var base_max_hp: = int(RoleProp.roleprop.SHp)
	var base_power: = int(RoleProp.roleprop.power)
	hero.get_action = "lhsq"
	hero._on_hit_box_area_entered(target_hurt_box)
	_check(hero.lhsq_awaken_stacks == 1, "灵魂摄取命中后没有增加觉醒层数")
	_check(int(RoleProp.roleprop.SHp) == int(round(base_max_hp * 1.2)), "灵魂摄取一层没有增加20%最大生命值")
	_check(int(RoleProp.roleprop.power) == int(round(base_power * 1.2)), "灵魂摄取一层没有增加20%攻击")

	for _hit in range(4):
		hero._on_hit_box_area_entered(target_hurt_box)
	_check(hero.lhsq_awaken_stacks == role4.LHSQ_AWAKEN_MAX_STACKS, "灵魂摄取觉醒没有叠加至五层")
	_check(int(RoleProp.roleprop.SHp) == base_max_hp * 2, "灵魂摄取五层最大生命值没有提升至两倍")
	_check(int(RoleProp.roleprop.power) == base_power * 2, "灵魂摄取五层攻击没有提升至两倍")

	hero.lhsq_awaken_time_left = 1.0
	hero._on_hit_box_area_entered(target_hurt_box)
	_check(hero.lhsq_awaken_stacks == role4.LHSQ_AWAKEN_MAX_STACKS, "灵魂摄取觉醒超过五层上限")
	_check(is_equal_approx(hero.lhsq_awaken_time_left, role4.LHSQ_AWAKEN_DURATION), "满层后再次命中没有刷新持续时间")
	hero._process_lhsq_awaken(9.9)
	_check(hero.lhsq_awaken_stacks == role4.LHSQ_AWAKEN_MAX_STACKS, "灵魂摄取觉醒未满10秒就提前失效")
	hero._process_lhsq_awaken(0.2)
	_check(hero.lhsq_awaken_stacks == 0, "灵魂摄取觉醒持续10秒后没有失效")
	_check(int(RoleProp.roleprop.SHp) == base_max_hp and int(RoleProp.roleprop.power) == base_power, "灵魂摄取觉醒失效后属性没有恢复")

	enabled_data["lhsq"] = false
	PlayerData.player_data["技能觉醒启用"] = enabled_data
	hero._on_hit_box_area_entered(target_hurt_box)
	_check(hero.lhsq_awaken_stacks == 0, "关闭觉醒后灵魂摄取仍然增加层数")

	print("SOUL_CAPTURE_AWAKEN_PROBE_OK")
	get_tree().quit()

func _spawn_target(parent: Node, target_position: Vector2) -> BaseMonster:
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	parent.add_child(target)
	target.global_position = target_position
	target.set_process(false)
	target.set_physics_process(false)
	target.Hp = 1000000
	target.SHp = 1000000
	target.spawn_damage_protection_until_msec = 0
	target.iniSpeed = target.speed
	target.is_death = false
	target.NoTarget = false
	target.is_boss = false
	target.boss_protect_active = false
	return target

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
