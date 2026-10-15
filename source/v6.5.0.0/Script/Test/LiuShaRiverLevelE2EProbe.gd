extends Node








const LEVEL_CASES: = [
	["res://Scene/Level/Level_xts.tscn", 31, "邪·唐僧"], 
	["res://Scene/Level/Level_xwk.tscn", 34, "邪·悟空"], 
	["res://Scene/Level/Level_xhy.tscn", 192, "邪·后羿"], 
]


const HIT_BUDGET_MS: = 20000

const CONTROL_MS: = 2500

var _failures: Array[String] = []
var _checks: = 0

class TurtleLinkProbe:
	extends Node
	var Hp: = 1
	func receive_linked_damage(_value: int) -> int:
		return 0


func _ready() -> void :
	Engine.time_scale = 3.0
	get_tree().create_timer(420.0, false).timeout.connect(_watchdog)
	call_deferred("_run")


func _watchdog() -> void :
	Engine.time_scale = 1.0
	print("LIUSHA_LEVEL_E2E_TIMEOUT")
	get_tree().quit(2)


func _check(condition: bool, message: String) -> void :
	_checks += 1
	if not condition:
		_failures.append(message)
		push_error("LEVEL_E2E_FAIL: " + message)


func _run() -> void :
	MainSet.set_data["Difficult"] = 0
	MainSet.set_data["MonsterBloodSHow"] = false
	MainSet.set_data["MonsterLittleBlood"] = false
	MainSet.set_data["NoShowMonsterBody"] = true
	MainSet.set_auto_battle_enabled(false)

	RoleProp.set_physics_process(false)
	PlayerData.player_data["头衔"] = []
	var previous_role_position: Variant = RoleProp.role_pos

	for case_data in LEVEL_CASES:
		await _run_case(str(case_data[0]), int(case_data[1]), str(case_data[2]))

	RoleProp.role_pos = previous_role_position
	Engine.time_scale = 1.0
	if _failures.is_empty():
		print("LIUSHA_LEVEL_E2E_OK (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		print("LIUSHA_LEVEL_E2E_FAILED: %d" % _failures.size())
		for failure in _failures:
			print("  - " + failure)
		get_tree().quit(1)


func _run_case(level_path: String, expected_kind: int, boss_name: String) -> void :
	var scene: = ResourceLoader.load(
		level_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE
	) as PackedScene
	_check(scene != null, "关卡无法加载: " + level_path)
	if scene == null:
		return
	var level: = scene.instantiate()
	add_child(level)

	for _i in range(10):
		await get_tree().process_frame

	var hero: Node2D = level.get("Role_") as Node2D
	if hero == null:
		hero = level.get_node_or_null("Hero") as Node2D
	_check(hero != null, "%s 关卡未创建英雄" % boss_name)
	if hero == null:
		level.queue_free()
		await get_tree().process_frame
		return


	Input.action_press("move_right")
	var entry_deadline: = Time.get_ticks_msec() + 10000
	while hero.position.x < 620 and Time.get_ticks_msec() < entry_deadline:
		await get_tree().physics_frame
	Input.action_release("move_right")
	_check(hero.position.x >= 600, "%s 无法用移动输入进入战斗区" % boss_name)
	var spawn_deadline: = Time.get_ticks_msec() + 10000
	while _find_boss(level) == null and Time.get_ticks_msec() < spawn_deadline:
		await get_tree().physics_frame

	var boss: = _find_boss(level)
	_check(boss != null, "%s 关卡未刷出 Boss" % boss_name)
	if boss == null:
		level.queue_free()
		await get_tree().process_frame
		return
	_check(
		int(boss.get("boss_kind")) == expected_kind, 
		"%s boss_kind 不符（期望 %d，实际 %s）" % [boss_name, expected_kind, str(boss.get("boss_kind"))]
	)

	var landing_deadline: = Time.get_ticks_msec() + 5000
	while not boss.is_on_floor() and Time.get_ticks_msec() < landing_deadline:
		await get_tree().physics_frame
	_check(boss.is_on_floor(), "%s 未正常落地" % boss_name)


	hero.set_physics_process(false)
	hero.set_process(false)


	hero.set("SXYRCannotCure", true)
	var turtle_link: = TurtleLinkProbe.new()
	add_child(turtle_link)
	hero.set_meta("pet_turtle_link_unit_ref", weakref(turtle_link))
	hero.set_meta("pet_turtle_link_until_msec", Time.get_ticks_msec() + 600000)
	hero.set_meta("pet_turtle_link_percent", 0)
	RoleProp.baseroleprop.Level = 90
	RoleProp.baseroleprop.SHp = 10000000
	RoleProp.roleprop.SHp = 10000000
	RoleProp.roleprop.Hp = 10000000
	RoleProp.roleprop.Miss = 0
	RoleProp.roleprop.CritReduce = 1000000
	RoleProp.roleprop.Toughness = 1000000
	RoleProp.roleprop.Def = 0
	RoleProp.roleprop.Mdef = 0
	hero.set("needProtect", false)
	hero.set("IsSuperArmor", true)

	for _i in range(10):
		await get_tree().physics_frame

	var boss_position: Vector2 = (boss as Node2D).global_position


	var far: = Vector2(boss_position.x + 2000.0, boss_position.y)
	_place_hero(hero, far)
	var control_before: = int(RoleProp.roleprop.Hp)
	var control_deadline: = Time.get_ticks_msec() + CONTROL_MS
	while Time.get_ticks_msec() < control_deadline:
		await get_tree().physics_frame
	var control_after: = int(RoleProp.roleprop.Hp)
	_check(
		control_after == control_before, 
		"%s 对照失败：英雄在感知范围外仍掉了血（%d -> %d），掉血来源不是 Boss 的攻击" % [
			boss_name, control_before, control_after, 
		]
	)


	var stand: = Vector2(boss_position.x - 150.0, boss_position.y)
	_place_hero(hero, stand)
	var hp_before: = int(RoleProp.roleprop.Hp)
	var skills_seen: = {}
	var attack_seen: = false
	var deadline: = Time.get_ticks_msec() + HIT_BUDGET_MS
	var hp_after: = hp_before
	while Time.get_ticks_msec() < deadline:
		var active: = str(boss.get("_active_skill"))
		if active != "":
			skills_seen[active] = true
			attack_seen = true
		elif bool(boss.get("is_attacking")):
			skills_seen["<普攻>"] = true
			attack_seen = true
		hp_after = int(RoleProp.roleprop.Hp)
		if hp_after < hp_before:
			break
		await get_tree().physics_frame
	_check(
		hp_after < hp_before, 
		"%s 在 %dms 内未对英雄造成伤害（boss=%s hero=%s 动作=%s）" % [
			boss_name, HIT_BUDGET_MS, boss_position, stand, str(boss.get("hit_name")), 
		]
	)
	_check(attack_seen, "%s 全程未进入攻击状态，掉血无法归因于 Boss 的攻击" % boss_name)
	if hp_after < hp_before:
		print(
			"  流沙河 %s 掉血 %d，期间攻击动作: %s" % [
				boss_name, hp_before - hp_after, ", ".join(skills_seen.keys()), 
			]
		)

	if expected_kind == 192:
		await _check_houyi_overlap(boss as LiuShaRiverBoss, hero)
	elif expected_kind == 31:
		boss.set_physics_process(false)
		boss.get("mr_player").stop()
		_place_hero(hero, Vector2(boss_position.x - 150, boss_position.y))
		boss.call("_execute_tang_event", "hit4_2")
		await get_tree().create_timer(0.55, false).timeout
	elif expected_kind == 34:
		boss.set_physics_process(false)
		boss.get("mr_player").stop()
		boss.set("_active_skill", "hit9")
		boss.set("is_attacking", true)
		boss.call("_execute_monkey_event", "hit9")
		(boss as Node2D).global_position.x -= 60.0
		await get_tree().create_timer(0.15, false).timeout
	await RenderingServer.frame_post_draw
	var screenshot: = get_viewport().get_texture().get_image()
	_check(
		screenshot.save_png("res://.codex_tmp/liusha_level_%d_20261009.png" % expected_kind) == OK, 
		"%s 实战截图保存失败" % boss_name
	)
	boss.set_physics_process(true)
	boss.set("_active_skill", "")
	boss.set("is_attacking", false)

	boss.set("Hp", 0)
	var death_deadline: = Time.get_ticks_msec() + 10000
	while is_instance_valid(boss) and Time.get_ticks_msec() < death_deadline:
		await get_tree().physics_frame
	_check( not is_instance_valid(boss), "%s 死亡动画没有完成清理" % boss_name)
	for _i in range(3):
		await get_tree().physics_frame
	_check(level.call("check_can_pass"), "%s 击败 Boss 后关卡不能通过" % boss_name)
	_check(level.get_node("exit").visible, "%s 击败 Boss 后出口没有开放" % boss_name)

	level.queue_free()
	for _i in range(3):
		await get_tree().process_frame


func _check_houyi_overlap(boss: LiuShaRiverBoss, hero: Node2D) -> void :
	boss.set_physics_process(false)
	boss.mr_player.stop()
	for direction in [-1.0, 1.0]:
		boss.monster_dir.scale.x = - direction
		for attack in ["hit1", "hit2", "hit3"]:
			for child in boss.get_children():
				if child is LiuShaRiverBoss.AttackOrigin:
					child.queue_free()
			_place_hero(hero, boss.global_position)
			hero.set("needProtect", false)
			await get_tree().physics_frame
			var hp: = int(RoleProp.roleprop.Hp)

			for _shot in range(8 if attack == "hit3" else 1):
				hero.set("needProtect", false)
				boss._execute_archer_event(attack)
				await get_tree().create_timer(0.3, false).timeout
				if int(RoleProp.roleprop.Hp) < hp:
					break
			_check(int(RoleProp.roleprop.Hp) < hp, "后羿 %s 朝向 %s 与英雄重叠时未命中" % [attack, direction])
	boss.set_physics_process(true)



func _place_hero(hero: Node2D, position: Vector2) -> void :
	hero.global_position = position
	RoleProp.role_pos = position
	RoleProp.role_pos_x = position.x
	RoleProp.role_pos_y = position.y



func _find_boss(level: Node) -> Node:
	var container: Node = level.get_node_or_null("Monster")
	if container != null:
		var found: = _search(container)
		if found != null:
			return found
	return _search(level)


func _search(root: Node) -> Node:
	if root.get_script() != null and root is LiuShaRiverBoss:
		return root
	for child in root.get_children():
		var found: = _search(child)
		if found != null:
			return found
	return null
