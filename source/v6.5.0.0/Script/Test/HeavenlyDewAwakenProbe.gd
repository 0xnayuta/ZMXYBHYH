extends Node

class ProbeHitSource extends Node:
	var hit_name: = "probe"

func _ready() -> void :
	call_deferred("_run")

func _run() -> void :
	PlayerData.player_data["Myself"] = 2
	PlayerData.player_data["玩家等级"] = 90
	PlayerData.player_data["技能学习"]["技能4"]["等级"] = 1
	var awaken_data: Dictionary = PlayerData.player_data.get("技能觉醒", {})
	awaken_data["tjgl"] = true
	PlayerData.player_data["技能觉醒"] = awaken_data
	var enabled_data: Dictionary = PlayerData.player_data.get("技能觉醒启用", {})
	enabled_data["tjgl"] = true
	PlayerData.player_data["技能觉醒启用"] = enabled_data

	var level: = (load("res://Scene/Level/Level_1.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(level)
	for _frame in range(24):
		await get_tree().process_frame

	var hero: = level.get("Role_") as role2
	var spawn_timer: = level.get_node_or_null("create_control") as Timer
	if spawn_timer != null:
		spawn_timer.stop()
	_check(hero != null, "天降甘露觉醒测试场景初始化失败")
	if hero == null:
		return
	hero.set_process(false)
	hero.set_physics_process(false)
	RoleProp.SourcePlayer = hero
	Global.get_player = hero

	var awaken_popup: = (load("res://Scene/Skill/SkillAwakenPopup.tscn") as PackedScene).instantiate()
	get_tree().root.add_child(awaken_popup)
	awaken_popup.configure("天降甘露", null, "tjgl")
	var description: = str(awaken_popup.get_node("EffectDescription").text)
	_check(description.contains("护盾不被击破不会消失") and description.contains("护盾存在期间免疫击退"), "天降甘露觉醒描述不正确")
	_check( not awaken_popup.get_node("AwakenEnabled").disabled, "天降甘露觉醒仍处于未开放状态")
	awaken_popup.queue_free()

	hero.shield_timer = Timer.new()
	hero.shield_timer.one_shot = true
	hero.add_child(hero.shield_timer)
	hero.shield_effect = Node2D.new()
	hero.add_child(hero.shield_effect)
	hero.hd = 500
	hero.shield_timer.start(15.0)
	hero.refresh_tjgl_shield_timer()
	_check(hero.shield_timer.is_stopped(), "觉醒天降甘露护盾仍在倒计时")
	hero._on_shield_timer_timeout()
	_check(hero.hd == 500 and hero.shield_effect != null, "觉醒天降甘露护盾未被击破却消失")

	var attacker: = BaseMonster.new()
	attacker.MonsterDirection = true
	attacker.objattackDic["probe"] = {"hurtBack": [8, -6], "attackKind": "physics", "power": 1}
	var hit_source: = ProbeHitSource.new()
	hero.velocity = Vector2.ZERO
	hero.be_hit_back(attacker, hit_source)
	_check(hero.velocity.is_zero_approx(), "天降甘露觉醒护盾存在期间没有免疫击退")
	hero.get_action = "wait"
	hero.is_be_attacking = true
	hero.state_behit()
	await get_tree().process_frame
	_check( not hero.is_be_attacking and hero.get_action != "hurt" and hero.role_action_player.current_animation != "hurt", "天降甘露觉醒护盾存在期间仍会播放受击动作")
	hero.hd = 0
	hero.be_hit_back(attacker, hit_source)
	_check( not hero.velocity.is_zero_approx(), "天降甘露护盾击破后仍然免疫击退")
	attacker.free()
	hit_source.free()

	hero.hd = 300
	enabled_data["tjgl"] = false
	PlayerData.player_data["技能觉醒启用"] = enabled_data
	hero.refresh_tjgl_shield_timer()
	_check( not hero.shield_timer.is_stopped() and hero.shield_timer.time_left > 14.0, "关闭觉醒后现存护盾没有恢复15秒计时")
	hero._on_shield_timer_timeout()
	_check(hero.hd == 0 and hero.shield_effect == null, "普通天降甘露护盾超时后没有消失")

	print("HEAVENLY_DEW_AWAKEN_PROBE_OK")
	get_tree().quit()

func _check(condition: bool, message: String) -> void :
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
