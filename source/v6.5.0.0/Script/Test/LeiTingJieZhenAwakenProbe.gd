extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 5
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能11"]["等级"] = 1
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["ltjz"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["ltjz"] = true
	PlayerData.player_data["技能觉醒启用"] = enabled_data

	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _frame in range(24):
		await get_tree().process_frame

	var hero: = level.get("Role_") as role5
	var monster_root: = level.get_node_or_null("Monster")
	var spawn_timer: = level.get_node_or_null("create_control") as Timer
	if spawn_timer != null:
		spawn_timer.stop()
	_check(hero != null and monster_root != null, "雷霆劫阵觉醒测试场景初始化失败")
	if hero == null or monster_root == null:
		return

	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame

	hero.set_process(false)
	hero.set_physics_process(false)
	hero.global_position = Vector2(500.0, 350.0)
	hero.PlayerDir = true
	RoleProp.SourcePlayer = hero
	Global.get_player = hero

	var near_target: = _spawn_target(monster_root, hero.global_position + Vector2(120.0, 0.0))
	var far_target: = _spawn_target(monster_root, hero.global_position + Vector2(520.0, 0.0))
	var ignored_summon: = _spawn_target(monster_root, hero.global_position + Vector2(900.0, 0.0))
	ignored_summon.set_meta("is_summon", true)
	await get_tree().process_frame

	_check(hero._get_farthest_ltjz_target() == far_target, "雷霆劫阵觉醒没有选中最远的有效目标")
	RoleProp.roleprop.Mp = 1000000
	hero.UseLTJZ()
	await get_tree().process_frame

	var effects: Array[LeiTingJieZhenEffect] = []
	for child in level.get_children():
		if child is LeiTingJieZhenEffect:
			effects.append(child)
	_check(effects.size() == 2, "雷霆劫阵觉醒施法后没有生成两个法阵")

	var target_effect: LeiTingJieZhenEffect = null
	for effect in effects:
		if bool(effect.get("_target_centered")):
			target_effect = effect
			break
	_check(target_effect != null, "没有找到最远目标位置的额外法阵")
	if target_effect != null:
		var expected_position: = far_target.global_position
		_check(target_effect.global_position.is_equal_approx(expected_position), "额外法阵没有生成在最远目标位置")
		hero.global_position += Vector2(180.0, 0.0)
		await get_tree().process_frame
		_check(target_effect.global_position.is_equal_approx(expected_position), "额外法阵错误地跟随白龙移动")

	_check(near_target != null and ignored_summon != null, "雷霆劫阵觉醒测试怪物生成失败")
	print("LEI_TING_JIE_ZHEN_AWAKEN_PROBE_OK")
	get_tree().quit()

func _spawn_target(parent: Node, target_position: Vector2) -> BaseMonster:
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	parent.add_child(target)
	target.global_position = target_position
	target.set_process(false)
	target.set_physics_process(false)
	target.Hp = 1000000
	target.SHp = 1000000
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
