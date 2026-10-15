extends Node

const SCREENSHOT_PATH: = "res://.tmp/fhf_awaken_probe.png"

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 5
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能4"]["等级"] = 1
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["fhf"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["fhf"] = true
	PlayerData.player_data["技能觉醒启用"] = enabled_data

	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _frame in range(24):
		await get_tree().process_frame

	var hero: = level.get("Role_") as role5
	var spawn_timer: = level.get_node_or_null("create_control") as Timer
	if spawn_timer != null:
		spawn_timer.stop()
	_check(hero != null, "翔龙闪觉醒测试场景初始化失败")
	if hero == null:
		return

	hero.global_position = Vector2(450.0, 350.0)
	RoleProp.SourcePlayer = hero
	Global.get_player = hero
	_check(hero._prepare_fhf_awaken_action(), "翔龙闪觉醒动画创建失败")

	var awaken_popup: = (load("res://Scene/Skill/SkillAwakenPopup.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(awaken_popup)
	awaken_popup.configure("翔龙闪", null, "fhf")
	var popup_description: = str(awaken_popup.get_node("EffectDescription").text)
	_check(popup_description.contains("前摇、后摇和冷却") and popup_description.contains("原来的三分之一"), "翔龙闪觉醒弹窗描述不正确")
	_check( not awaken_popup.get_node("AwakenEnabled").disabled, "翔龙闪觉醒仍显示为未开放")
	awaken_popup.queue_free()

	var library: = hero.role_action_player.get_animation_library("")
	var normal_action: = library.get_animation(&"fhf")
	var awaken_action: = library.get_animation(role5.FHF_AWAKEN_ACTION)
	_check(normal_action != null and awaken_action != null, "翔龙闪动画资源缺失")
	if normal_action == null or awaken_action == null:
		return
	_check(is_equal_approx(awaken_action.length, hero._remap_fhf_awaken_time(normal_action.length)), "翔龙闪觉醒动画总时长不正确")
	_check(is_equal_approx(_get_method_time(awaken_action, &"RoleRush5"), 0.1), "翔龙闪觉醒前摇没有缩短三倍")
	_check(is_equal_approx(_get_method_time(awaken_action, &"RemoveXspeed"), 0.3), "翔龙闪冲刺有效时长被错误改变")

	hero.UseFHF()
	_check(is_equal_approx(hero.Role1SkillInter["fhf"], role5.FHF_AWAKEN_COOLDOWN), "翔龙闪觉醒冷却没有缩短三倍")
	_check(hero.role_action_player.current_animation == str(role5.FHF_AWAKEN_ACTION), "翔龙闪没有播放觉醒动画")

	await get_tree().create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	var screenshot_path: = ProjectSettings.globalize_path(SCREENSHOT_PATH)
	DirAccess.make_dir_recursive_absolute(screenshot_path.get_base_dir())
	var image: = get_viewport().get_texture().get_image()
	_check(image != null and not image.is_empty(), "翔龙闪觉醒验证截图为空")
	if image != null and not image.is_empty():
		_check(image.save_png(screenshot_path) == OK, "翔龙闪觉醒验证截图保存失败")

	await hero.role_action_player.animation_finished
	enabled_data["fhf"] = false
	PlayerData.player_data["技能觉醒启用"] = enabled_data
	hero.Role1SkillInter["fhf"] = 0.0
	hero.UseFHF()
	_check(is_equal_approx(hero.Role1SkillInter["fhf"], role5.FHF_NORMAL_COOLDOWN), "关闭觉醒后翔龙闪冷却没有恢复")
	_check(hero.role_action_player.current_animation == "fhf", "关闭觉醒后翔龙闪动画没有恢复")
	await hero.role_action_player.animation_finished

	print("XIANG_LONG_SHAN_AWAKEN_PROBE_OK")
	get_tree().quit()

func _get_method_time(animation: Animation, method_name: StringName) -> float:
	for track_index in range(animation.get_track_count()):
		if animation.track_get_type(track_index) != Animation.TYPE_METHOD:
			continue
		for key_index in range(animation.track_get_key_count(track_index)):
			var method_data: Variant = animation.track_get_key_value(track_index, key_index)
			if method_data is Dictionary and method_data.get("method", &"") == method_name:
				return animation.track_get_key_time(track_index, key_index)
	return -1.0

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
