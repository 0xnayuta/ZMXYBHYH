extends Node

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 4
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能9"]["等级"] = 1
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["wdww"] = false
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["wdww"] = true
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
	_check(hero != null and monster_root != null, "巫毒娃娃觉醒测试场景初始化失败")
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

	var targets: Array[BaseMonster] = []
	for index in range(5):
		targets.append(_spawn_target(monster_root, Vector2(700.0 + index * 80.0, 350.0), (index + 1) * 10000))
	await get_tree().process_frame

	var awaken_popup: = (load("res://Scene/Skill/SkillAwakenPopup.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(awaken_popup)
	awaken_popup.configure("巫毒娃娃", null, "wdww")
	_check(str(awaken_popup.get_node("EffectDescription").text).contains("可连接四个敌人"), "巫毒娃娃觉醒描述不正确")
	_check( not awaken_popup.get_node("ConfirmButton").disabled, "巫毒娃娃觉醒仍处于未开放状态")
	awaken_popup.queue_free()

	hero.CallWDWW()
	await get_tree().process_frame
	var normal_doll: = hero.WDWW
	_check(normal_doll != null and normal_doll.LinkedTargets.size() == 1, "未觉醒巫毒娃娃没有保持单目标连接")
	if normal_doll == null:
		return
	normal_doll.queue_free()
	await get_tree().process_frame

	awaken_data["wdww"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	hero.CallWDWW()
	await get_tree().process_frame
	var awakened_doll: = hero.WDWW
	_check(awakened_doll != null and awakened_doll.LinkedTargets.size() == role4.WDWW_AWAKEN_TARGET_LIMIT, "觉醒巫毒娃娃没有连接四个敌人")
	if awakened_doll == null:
		return
	awakened_doll.set_process(false)
	awakened_doll.set_physics_process(false)

	for index in range(1, targets.size()):
		_check(awakened_doll.LinkedTargets.has(targets[index]), "觉醒巫毒娃娃没有优先连接生命较高的四个敌人")
	_check( not awakened_doll.LinkedTargets.has(targets[0]), "觉醒巫毒娃娃错误连接了第五个敌人")

	var hp_before: Array[int] = []
	for target in targets:
		hp_before.append(target.Hp)
	awakened_doll.transfer_linked_damage(100)
	for index in range(targets.size()):
		if index == 0:
			_check(targets[index].Hp == hp_before[index], "未连接的第五个敌人错误承受了娃娃传递伤害")
		else:
			_check(targets[index].Hp < hp_before[index], "连接目标没有承受娃娃传递伤害")

	print("VOODOO_DOLL_AWAKEN_PROBE_OK")
	get_tree().quit()

func _spawn_target(parent: Node, target_position: Vector2, health: int) -> BaseMonster:
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	parent.add_child(target)
	target.global_position = target_position
	target.set_process(false)
	target.set_physics_process(false)
	target.Hp = health
	target.SHp = health
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
