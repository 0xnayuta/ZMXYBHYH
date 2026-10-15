extends Node

const SCREENSHOT_PATH: = "res://.tmp/tllz_awaken_probe.png"

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 5
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能9"]["等级"] = 1

	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["tllz"] = false
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["tllz"] = true
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
	_check(hero != null and monster_root != null, "天龙雷阵觉醒测试场景初始化失败")
	if hero == null or monster_root == null:
		return

	for child in monster_root.get_children():
		if child is BaseMonster:
			child.queue_free()
	await get_tree().process_frame

	hero.set_process(false)
	hero.set_physics_process(false)
	hero.global_position = Vector2(500.0, 350.0)
	RoleProp.SourcePlayer = hero
	Global.get_player = hero

	var target: = _spawn_target(monster_root, Vector2(780.0, 350.0))
	await get_tree().process_frame
	var original_bullet: = Global.addRoleBullet_(
		hero.Bullet, 
		hero.global_position - Vector2(0.0, 20.0), 
		false, 
		"Role5Bullet4", 
		hero.objattackDic["tllz"]
	) as RoleBullet
	_check(original_bullet != null, "天龙雷阵测试弹体创建失败")
	if original_bullet == null:
		return
	original_bullet.Player = hero
	original_bullet.is_set = true

	original_bullet._apply_tllz_awaken_effect(target)
	await get_tree().physics_frame
	_check(_get_tllz_awaken_extras(hero.Bullet).is_empty(), "未觉醒时错误地生成了额外雷阵")
	_check( not target.IsDefeReduce, "未觉醒时错误地降低了目标防御")

	awaken_data["tllz"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	original_bullet._apply_tllz_awaken_effect(target)
	await get_tree().physics_frame
	target.CheckAddBuff()

	_check(target.IsDefeReduce, "觉醒后的天龙雷阵没有触发减防")
	_check(is_equal_approx(target.get_effective_defense_reduction(), 0.5), "觉醒减防数值不是50%")
	var extra_bullets: = _get_tllz_awaken_extras(hero.Bullet)
	_check(extra_bullets.size() == 1, "觉醒命中后没有额外生成一个雷阵")

	var extra_bullet: RoleBullet = extra_bullets[0] if not extra_bullets.is_empty() else null
	_check(extra_bullet != null and extra_bullet.tllz_awaken_extra, "额外雷阵没有正确标记")
	if extra_bullet != null:
		_check(extra_bullet.global_position.is_equal_approx(target.global_position), "额外雷阵没有生成在目标位置")
		extra_bullet.Player = hero
		extra_bullet._apply_tllz_awaken_effect(target)
		await get_tree().physics_frame
		_check(_get_tllz_awaken_extras(hero.Bullet).size() == 1, "额外雷阵命中后发生了递归生成")

	await RenderingServer.frame_post_draw
	var screenshot_path: = ProjectSettings.globalize_path(SCREENSHOT_PATH)
	DirAccess.make_dir_recursive_absolute(screenshot_path.get_base_dir())
	var image: = get_viewport().get_texture().get_image()
	_check(image != null and not image.is_empty(), "天龙雷阵觉醒验证截图为空")
	if image != null and not image.is_empty():
		_check(image.save_png(screenshot_path) == OK, "天龙雷阵觉醒验证截图保存失败")

	print("TIAN_LONG_LEI_ZHEN_AWAKEN_PROBE_OK")
	get_tree().quit()

func _spawn_target(parent: Node, target_position: Vector2) -> BaseMonster:
	var target: = (load("res://Scene/Monster/Monster_3008.tscn") as PackedScene).instantiate() as BaseMonster
	parent.add_child(target)
	target.global_position = target_position
	target.set_process(false)
	target.set_physics_process(false)
	target.Hp = 1000000
	target.SHp = 1000000
	target.iniSpeed = target.speed
	target.is_death = false
	target.NoTarget = false
	target.is_boss = false
	target.boss_protect_active = false
	return target

func _get_tllz_awaken_extras(bullet_root: Node) -> Array[RoleBullet]:
	var extras: Array[RoleBullet] = []
	for child in bullet_root.get_children():
		if child is RoleBullet and child.tllz_awaken_extra:
			extras.append(child as RoleBullet)
	return extras

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
