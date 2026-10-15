extends Node

const SCREENSHOT_PATH: = "res://.tmp/ygth_awaken_probe.png"

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 5
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能8"]["等级"] = 1
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["ygth"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["ygth"] = true
	PlayerData.player_data["技能觉醒启用"] = enabled_data

	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _frame in range(24):
		await get_tree().process_frame

	var hero: = level.get("Role_") as role5
	var spawn_timer: = level.get_node_or_null("create_control") as Timer
	if spawn_timer != null:
		spawn_timer.stop()
	_check(hero != null, "银钩铁画觉醒测试场景初始化失败")
	if hero == null:
		return

	hero.global_position = Vector2(420.0, 350.0)
	hero.PlayerDir = true
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	_check(hero._prepare_ygth_awaken_action(), "银钩铁画觉醒动画创建失败")

	var awaken_popup: = (load("res://Scene/Skill/SkillAwakenPopup.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(awaken_popup)
	awaken_popup.configure("银钩铁画", null, "ygth")
	var popup_description: = str(awaken_popup.get_node("EffectDescription").text)
	_check(popup_description.contains("三次巨型银钩") and popup_description.contains("三倍") and popup_description.contains("0.8秒"), "银钩铁画觉醒弹窗描述不正确")
	_check( not awaken_popup.get_node("AwakenEnabled").disabled, "银钩铁画觉醒仍显示为未开放")
	awaken_popup.queue_free()

	var library: = hero.role_action_player.get_animation_library("")
	var awaken_action: = library.get_animation(role5.YGTH_AWAKEN_ACTION)
	_check(awaken_action != null and is_equal_approx(awaken_action.length, 0.6), "银钩铁画觉醒短动作未正确创建")
	if awaken_action == null:
		return
	_check(_count_method_keys(awaken_action, &"CallYGTHAwakenBullet") == 3, "银钩铁画觉醒没有配置三次银钩释放")
	_check(_first_body_frame(awaken_action) == 120, "银钩铁画觉醒仍从前段挥枪动作开始")

	for facing_right in [false, true]:
		hero.PlayerDir = facing_right
		hero.CallYGTHAwakenBullet()
		await get_tree().process_frame
		var direction_hooks: = _get_awaken_hooks(hero.Bullet)
		_check( not direction_hooks.is_empty(), "觉醒银钩方向测试未生成银钩")
		if direction_hooks.is_empty():
			return
		var direction_hook: = direction_hooks.back() as RoleBullet
		_check(direction_hook.Direction == !facing_right, "修复击退时改变了觉醒银钩特效方向")
		var monster: = BaseMonster.new()
		monster.be_hit_back(direction_hook)
		var expected_knockback_sign: = 1.0 if facing_right else -1.0
		_check(monster.velocity.x * expected_knockback_sign > 0.0, "觉醒银钩没有将怪物向远离角色的方向击退")
		monster.free()
		direction_hook.free()

	var normal_power: = float(hero.objattackDic["ygth"]["power"])
	hero.PlayerDir = true
	hero.UseYGTH()
	_check(is_equal_approx(hero.Role1SkillInter["ygth"], role5.YGTH_AWAKEN_COOLDOWN), "银钩铁画觉醒冷却不是0.8秒")
	_check(hero.role_action_player.current_animation == str(role5.YGTH_AWAKEN_ACTION), "银钩铁画没有播放觉醒短动作")
	await get_tree().create_timer(0.45).timeout

	var hooks: = _get_awaken_hooks(hero.Bullet)
	_check(hooks.size() == 3, "银钩铁画觉醒没有释放三次巨型银钩")
	for hook in hooks:
		_check(hook.scale.is_equal_approx(role5.YGTH_AWAKEN_SCALE), "觉醒银钩没有放大")
		_check(is_equal_approx(float(hook.HitDic["power"]), normal_power * role5.YGTH_AWAKEN_DAMAGE_MULTIPLIER), "觉醒银钩伤害不是普通银钩的三倍")

	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot_path: = ProjectSettings.globalize_path(SCREENSHOT_PATH)
		DirAccess.make_dir_recursive_absolute(screenshot_path.get_base_dir())
		var image: = get_viewport().get_texture().get_image()
		_check(image != null and not image.is_empty(), "银钩铁画觉醒验证截图为空")
		if image != null and not image.is_empty():
			_check(image.save_png(screenshot_path) == OK, "银钩铁画觉醒验证截图保存失败")

	await get_tree().create_timer(0.2).timeout
	enabled_data["ygth"] = false
	PlayerData.player_data["技能觉醒启用"] = enabled_data
	hero.Role1SkillInter["ygth"] = 0.0
	hero.UseYGTH()
	_check(is_equal_approx(hero.Role1SkillInter["ygth"], role5.YGTH_NORMAL_COOLDOWN), "关闭觉醒后银钩铁画冷却没有恢复")
	_check(hero.role_action_player.current_animation == "ygth", "关闭觉醒后银钩铁画没有恢复普通动作")
	hero.role_action_player.stop()

	print("YIN_GOU_TIE_HUA_AWAKEN_PROBE_OK")
	get_tree().quit()

func _count_method_keys(animation: Animation, method_name: StringName) -> int:
	var count: = 0
	for track_index in range(animation.get_track_count()):
		if animation.track_get_type(track_index) != Animation.TYPE_METHOD:
			continue
		for key_index in range(animation.track_get_key_count(track_index)):
			var method_data: Variant = animation.track_get_key_value(track_index, key_index)
			if method_data is Dictionary and method_data.get("method", &"") == method_name:
				count += 1
	return count

func _first_body_frame(animation: Animation) -> int:
	for track_index in range(animation.get_track_count()):
		if animation.track_get_path(track_index) == NodePath("Action/RoleBody:frame"):
			return int(animation.track_get_key_value(track_index, 0))
	return -1

func _get_awaken_hooks(bullet_root: Node) -> Array[RoleBullet]:
	var hooks: Array[RoleBullet] = []
	for child in bullet_root.get_children():
		if child is RoleBullet and bool(child.get_meta("ygth_awakened", false)):
			hooks.append(child as RoleBullet)
	return hooks

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
