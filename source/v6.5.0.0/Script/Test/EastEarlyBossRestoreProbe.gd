extends Node2D

const MONSTER_SCENE: = preload("res://Scene/Monster/EastContinentMonster.tscn")
const OUTPUT_PATH: = "res://.tmp/east_early_boss_restore.png"

var _failed: = false


func _ready() -> void :
	call_deferred("_run")


func _run() -> void :
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	var background: = ColorRect.new()
	background.color = Color("17212b")
	background.size = Vector2(1152.0, 648.0)
	background.z_index = -100
	add_child(background)

	var white_ape: = await _spawn_monster(3161, Vector2(290.0, 470.0))
	var six_ear: = await _spawn_monster(3179, Vector2(800.0, 470.0))
	_check_animations(white_ape, 4)
	_check_animations(six_ear, 5)
	_check_attack_power(white_ape, &"hit1", 0.25)
	_check_attack_power(white_ape, &"hit3", 1.5)
	_check_attack_power(six_ear, &"hit1", 0.375)
	_check_attack_power(six_ear, &"hit3", 0.34)
	_check(
		MonsterAtlasSequence.sequence_frame_count(six_ear._manifest_path(), "hit4") == 28, 
		"六耳猕猴嗜血火眼应为官方28帧"
	)
	_check(
		MonsterAtlasSequence.sequence_frame_count(six_ear._manifest_path(), "hit5") == 120, 
		"六耳猕猴火魔斩本体应为官方120帧"
	)

	white_ape._start_3161_attack(&"hit1", 0)
	await get_tree().process_frame
	var ape_pulse: = _find_skill(white_ape, "East3161_hit1Pulse")
	_check(ape_pulse != null and ape_pulse.max_hits == 8, "通臂飞拳应命中8段")
	_check(
		ape_pulse != null and is_equal_approx(ape_pulse.damage_pulse_interval, 0.134), 
		"通臂飞拳段间隔应为134毫秒"
	)

	six_ear._start_3179_attack(&"hit3", 0)
	await get_tree().process_frame
	var storm: = _find_skill(six_ear, "East3179_hit3Pulse")
	_check(storm != null and storm.max_hits == 3, "烈焰风暴应命中3段")
	_check(
		storm != null and is_equal_approx(storm.damage_pulse_interval, 0.167), 
		"烈焰风暴段间隔应为167毫秒"
	)

	var dash_ape: = await _spawn_monster(3161, Vector2(170.0, 610.0))
	dash_ape._attack_serial = 1
	dash_ape.MonsterDirection = true
	var dash_start: = dash_ape.global_position.x
	dash_ape._start_3161_effect3(1)
	await get_tree().create_timer(0.58, false).timeout
	_check(
		absf((dash_ape.global_position.x - dash_start) - 600.0) <= 45.0, 
		"崩山直拳位移应接近600像素"
	)

	var fire_monkey: = await _spawn_monster(3179, Vector2(630.0, 610.0))
	fire_monkey._attack_serial = 1
	fire_monkey.MonsterDirection = true
	var fire_slash_start_x: = fire_monkey.global_position.x
	fire_monkey._start_six_ear_dash(1)
	await get_tree().create_timer(0.2, false).timeout
	var air_slash: = _find_skill(fire_monkey, "SixEarEffect5_1")
	_check(air_slash != null and air_slash.max_hits == 11, "火魔斩空中斩应命中11段")
	_check(
		air_slash != null and is_equal_approx(air_slash.motion_velocity.x, 150.0), 
		"火魔斩飞行速度应为150像素每秒"
	)
	_check(
		air_slash != null and int(air_slash.AttList.get("power", 0))\
		== roundi(float(fire_monkey.attack_in) * 0.1), 
		"火魔斩空中斩倍率应为0.1"
	)
	await get_tree().create_timer(1.05, false).timeout
	var impact: = _find_skill(fire_monkey, "SixEarEffect51")
	_check(impact != null and impact.max_hits == 1, "火魔斩应衔接1段落地重击")
	_check(
		impact != null and int(impact.AttList.get("power", 0)) == fire_monkey.attack_in, 
		"火魔斩落地重击倍率应为1.0"
	)
	_check(
		fire_monkey._3179_fire_slash_invincible, 
		"火魔斩飞行和落地冲击期间应保持无敌"
	)
	_check(
		absf(fire_monkey.global_position.x - (fire_slash_start_x + 332.0)) <= 20.0, 
		"火魔斩结束后模型没有移动到最终坠落位置"
	)
	await get_tree().create_timer(0.65, false).timeout
	_check(
		not fire_monkey._3179_fire_slash_invincible and not fire_monkey._special_attack_active, 
		"火魔斩落地特效结束后没有解除无敌或攻击状态"
	)

	dash_ape.queue_free()
	fire_monkey.queue_free()
	await get_tree().process_frame
	_show_action(white_ape, &"hit4", 13)
	_show_action(six_ear, &"hit5", _largest_visual_frame(six_ear, &"hit5"))
	_add_label("3161 通臂白猿 - 逆击乾坤", Vector2(125.0, 50.0))
	_add_label("3179 六耳猕猴 - 火魔斩", Vector2(650.0, 50.0))
	await get_tree().process_frame
	await get_tree().process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://.tmp"))
	var image: = get_viewport().get_texture().get_image()
	var screenshot_path: = ProjectSettings.globalize_path(OUTPUT_PATH)
	_check(image != null and image.save_png(screenshot_path) == OK, "无法保存技能截图")
	if not _failed:
		print("EAST_EARLY_BOSS_RESTORE_PROBE_OK screenshot=" + screenshot_path)
	get_tree().quit(1 if _failed else 0)


func _spawn_monster(monster_id: int, spawn_position: Vector2) -> EastContinentMonster:
	var monster: = MONSTER_SCENE.instantiate() as EastContinentMonster
	monster.monster_kind = monster_id
	monster.position = spawn_position
	add_child(monster)
	await get_tree().process_frame
	monster.set_physics_process(false)
	return monster


func _check_animations(monster: EastContinentMonster, attack_count: int) -> void :
	for index in range(1, attack_count + 1):
		_check(
			monster.mr_player.has_animation(StringName("hit%d" % index)), 
			"%d 缺少hit%d" % [monster.monster_kind, index]
		)


func _check_attack_power(
	monster: EastContinentMonster, attack_name: StringName, multiplier: float
) -> void :
	_check(
		int(monster._attack_entry(attack_name).get("power", 0))\
		== roundi(float(monster.attack_in) * multiplier), 
		"%d %s 倍率错误" % [monster.monster_kind, attack_name]
	)


func _find_skill(monster: EastContinentMonster, name: String) -> WutaiMinghaiProjectile:
	for child in monster.bullet.get_children():
		if child is WutaiMinghaiProjectile and child.skill_name == name:
			return child as WutaiMinghaiProjectile
	return null


func _show_action(monster: EastContinentMonster, action: StringName, frame: int) -> void :
	monster._play_frames(action)
	monster.mr_ani.frame = clampi(
		frame, 0, monster.mr_ani.sprite_frames.get_frame_count(action) - 1
	)
	monster.set_process(false)


func _largest_visual_frame(monster: EastContinentMonster, action: StringName) -> int:
	var result: = 0
	var max_area: = 0.0
	var frame_count: = MonsterAtlasSequence.sequence_frame_count(
		monster._manifest_path(), str(action)
	)
	for frame_index in range(frame_count):
		var geometry: = MonsterAtlasSequence.frame_geometry(
			monster._manifest_path(), str(action), frame_index
		)
		if not bool(geometry.get("has_visual", false)):
			continue
		var size: = geometry.get("size", Vector2.ZERO) as Vector2
		var area: = size.x * size.y
		if area > max_area:
			max_area = area
			result = frame_index
	return result


func _add_label(text: String, label_position: Vector2) -> void :
	var label: = Label.new()
	label.text = text
	label.position = label_position
	label.add_theme_color_override("font_color", Color("e7edf3"))
	label.add_theme_font_size_override("font_size", 24)
	add_child(label)


func _check(condition: bool, message: String) -> void :
	if condition:
		return
	_failed = true
	push_error("EAST_EARLY_BOSS_RESTORE_PROBE_FAIL " + message)
