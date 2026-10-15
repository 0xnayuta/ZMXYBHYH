extends Node





const BOSS_CASES: = [
	[
		"res://Scene/Monster/Monster_13101.tscn", "邪·唐僧", 31, 
		{
			"wait": 10, "walk": 4, "jump1": 1, "jump2": 5, "jump3": 1, "hurt": 1, 
			"hit1": 3, "hit3": 4, "hit4_1": 2, "hit4_2": 3, "hit5": 3, "hit6": 3, 
			"hit7": 3, "hit8": 1, "hit9": 1, 
		}, 
	], 
	[
		"res://Scene/Monster/Monster_13401.tscn", "邪·悟空", 34, 
		{
			"wait": 8, "walk": 4, "jump1": 1, "jump2": 5, "jump3": 1, "hurt": 1, 
			"hit1": 5, "hit3": 5, "hit4": 5, "hit5": 5, "hit6": 4, "hit7": 1, 
			"hit8": 4, "hit9": 1, "hit10": 1, "hit11_1": 1, "hit11_2": 1, 
			"hit12": 1, "hit13": 1, "hit14": 3, 
		}, 
	], 
	[
		"res://Scene/Monster/Monster_19201.tscn", "邪·后羿", 192, 
		{
			"wait": 6, "walk": 4, "hurt": 1, "death": 5, 
			"hit1": 7, "hit2": 7, "hit3": 2, 
		}, 
	], 
]

const LEVEL_CASES: = [
	["res://Scene/Level/Level_xts.tscn", 13101], 
	["res://Scene/Level/Level_xwk.tscn", 13401], 
	["res://Scene/Level/Level_xhy.tscn", 19201], 
]

var _failures: Array[String] = []


func _ready() -> void :
	get_tree().create_timer(240.0, false).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void :
	print("LIUSHA_BOSS_PROBE_TIMEOUT")
	get_tree().quit(2)


func _check(condition: bool, message: String) -> void :
	if not condition:
		_failures.append(message)
		push_error(message)


func _run() -> void :
	var previous_role_position: Variant = RoleProp.role_pos
	RoleProp.role_pos = Vector2(520, 240)
	for case_data in BOSS_CASES:
		var scene: = load(str(case_data[0])) as PackedScene
		_check(scene != null, "Boss scene failed to load: " + str(case_data[0]))
		if scene == null:
			continue
		var boss: = scene.instantiate() as LiuShaRiverBoss
		_check(boss != null, "Boss scene has the wrong root script: " + str(case_data[0]))
		if boss == null:
			continue
		boss.process_mode = Node.PROCESS_MODE_DISABLED
		add_child(boss)
		await get_tree().process_frame

		boss.monster_dir.scale.x = -1
		_check(boss.my_mr_name == str(case_data[1]), "Wrong boss name: " + str(case_data[0]))
		_check(boss.boss_kind == int(case_data[2]), "Wrong boss kind: " + str(case_data[0]))
		var fragment_id: String = {31: "yxsp_1", 34: "yxsp_2", 192: "yxsp_3"}[boss.boss_kind]
		_check(is_equal_approx(boss.fall_pro, 0.5), "%s 碎片掉落概率应为 50%%" % boss.my_mr_name)
		_check(boss.fall_list == [{"name": fragment_id, "value": 1}], "%s 碎片种类或数量错误" % boss.my_mr_name)

		var source_offset: Vector2 = {31: Vector2(-15, 0), 34: Vector2(-5, -15), 192: Vector2(-2, -30)}[boss.boss_kind]
		var origin_shift: Vector2 = {31: Vector2(0, -54), 34: Vector2(0, -55), 192: Vector2(0, -57)}[boss.boss_kind]
		boss._play_body_action("wait")
		for direction in [1.0, -1.0]:
			boss.monster_dir.scale.x = direction
			_check(boss.mr_ani.position == source_offset + origin_shift, 
				"%s 本体注册点不符合原版 setXYByDirect" % boss.my_mr_name)
			_check(boss._world(Vector2(50, 10)) == boss.to_global(origin_shift + Vector2(50, 10)), 
				"%s 技能未转换原版中心原点" % boss.my_mr_name)
		boss.monster_dir.scale.x = -1
		var expected_frames: Dictionary = case_data[3]
		for action_name in expected_frames:
			boss._play_body_action(str(action_name))
			var expected_position: = source_offset + origin_shift
			if boss.boss_kind == 34 and action_name == "hit14":
				expected_position.y -= 15
			for frame_index in range(int(expected_frames[action_name])):
				boss.mr_ani.frame = frame_index
				boss._align_body_frame()
				_check(boss.mr_ani.offset == Vector2.ZERO and boss.mr_ani.position == expected_position, 
					"%s/%s 第 %d 帧改变了固定画布注册点" % [boss.my_mr_name, action_name, frame_index])
			_check(
				boss.mr_player.has_animation(str(action_name)), 
				"%s 缺少动作 %s" % [boss.my_mr_name, action_name]
			)
			_check(
				boss.mr_ani.sprite_frames.get_frame_count(str(action_name))
				== int(expected_frames[action_name]), 
				"帧数不符: %s/%s (%d != %d)" % [
					case_data[0], action_name, 
					boss.mr_ani.sprite_frames.get_frame_count(str(action_name)), 
					int(expected_frames[action_name]), 
				]
			)


		var no_effect_events: = ["hit13", "hit10_1"]
		var events: Dictionary = LiuShaRiverBoss.ATTACK_EVENTS[boss.boss_kind]
		for event_name in events:
			var spawns: = false
			for entry in events[event_name]:
				if no_effect_events.has(str(entry[1])):
					continue
				spawns = true
			if not spawns:
				continue
			var before_count: = boss.get_child_count()
			for entry in events[event_name]:
				boss._execute_attack_event(str(entry[1]))
			_check(
				boss.get_child_count() > before_count, 
				"%s 的事件 %s 没有创建攻击判定或特效" % [boss.my_mr_name, event_name]
			)
		for child in boss.get_children():
			if child is LiuShaRiverBoss.AttackOrigin:
				var area: = child.get_node_or_null("BaseDamageBox/HitBox") as Area2D
				_check(area != null, "攻击特效缺少兼容英雄受击逻辑的节点层级")
				if area != null:
					_check(area.get_parent().get_parent() == child, "英雄读取的伤害源不是独立特效")
				var original_name: String = child.hit_name
				boss.hit_name = "hit1"
				_check(child.hit_name == original_name and child.objattackDic.has(original_name), "Boss 换招覆盖了旧特效的伤害数据")
		if boss.boss_kind == 31:
			_check(is_equal_approx(boss.mr_player.get_animation("hit4_1").length, 0.5), "邪·唐僧落柱前置切招应为 0.5 秒")
		elif boss.boss_kind == 34:
			_check(is_equal_approx(boss.mr_player.get_animation("hit11_1").length, 1.0), "邪·悟空连招切招应为 1 秒")
		boss.queue_free()
		await get_tree().process_frame

	for case_data in LEVEL_CASES:
		var scene: = load(str(case_data[0])) as PackedScene
		_check(scene != null, "Level scene failed to load: " + str(case_data[0]))
		if scene == null:
			continue
		var level: = scene.instantiate()
		_check(level.get("boss_scene_id") == int(case_data[1]), "Wrong level boss id: " + str(case_data[0]))
		level.free()

	RoleProp.role_pos = previous_role_position
	if _failures.is_empty():
		print("LIUSHA_BOSS_PROBE_OK")
		get_tree().quit(0)
	else:
		print("LIUSHA_BOSS_PROBE_FAILED: %d" % _failures.size())
		get_tree().quit(1)
