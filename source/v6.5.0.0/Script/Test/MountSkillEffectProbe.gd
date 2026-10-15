extends SceneTree

class ProbeLevel extends Node2D:
	var lj_tt: Node2D

	func _init() -> void :
		lj_tt = Node2D.new()
		lj_tt.name = "ComboHost"
		add_child(lj_tt)

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _run() -> void :
	var role_prop_node: = root.get_node_or_null("RoleProp")
	var global_node: = root.get_node_or_null("Global")
	var main_set_node: = root.get_node_or_null("MainSet")
	_check(role_prop_node != null, "RoleProp Autoload 未加载")
	_check(global_node != null, "Global Autoload 未加载")
	_check(main_set_node != null, "MainSet Autoload 未加载")
	if role_prop_node == null or global_node == null or main_set_node == null:
		quit(1)
		return
	var role_properties: Dictionary = role_prop_node.get("roleprop")
	var base_role_properties: Dictionary = role_prop_node.get("baseroleprop")
	var old_source: Variant = role_prop_node.get("SourcePlayer")
	var old_role_properties: = role_properties.duplicate(true)
	var old_base_role_properties: = base_role_properties.duplicate(true)
	var old_ws_up_power: Variant = role_prop_node.get("ws_up_power")
	var old_total_role_hit: Variant = global_node.get("TotalRoleHit")
	var old_total_magic_hit: Variant = global_node.get("TotalMagHit")
	var old_total_hit_count: Variant = global_node.get("TotalHitCount")
	var old_ws_value: Variant = role_prop_node.get("ws_value")
	var old_ws_state: Variant = role_prop_node.get("is_ws_state")
	var main_set_data: Dictionary = main_set_node.get("set_data")
	var old_show_damage_text: Variant = main_set_data.get("ShowDamageText", true)
	main_set_data["ShowDamageText"] = false
	var hero_scene: = load("res://Scene/Hero/Role_3/Role_3.tscn") as PackedScene
	var target_scene: = load("res://Scene/Monster/Monster_1.tscn") as PackedScene
	var effect_script: = load("res://Script/Mount/MountSkillEffect.gd")
	_check(hero_scene != null, "Role3 场景无法加载")
	_check(target_scene != null, "测试怪物场景无法加载")
	_check(effect_script != null, "坐骑技能效果脚本无法加载")
	if hero_scene == null or target_scene == null or effect_script == null:
		quit(1)
		return
	var hero = hero_scene.instantiate()
	var target = target_scene.instantiate()
	var level: = ProbeLevel.new()
	level.name = "ProbeLevel"
	root.add_child(level)
	current_scene = level
	target.process_mode = Node.PROCESS_MODE_DISABLED
	level.add_child(target)
	await process_frame
	var original_hit_data: Dictionary = hero.HitDic.duplicate(true)
	role_prop_node.set("SourcePlayer", hero)
	role_properties["power"] = 1000
	role_properties["Htarget"] = 100000
	role_properties["Crit"] = 0
	role_properties["Lucky"] = 0
	role_properties["sp"] = 100000
	base_role_properties["Level"] = 90
	role_prop_node.set("ws_up_power", 1.0)
	role_prop_node.set("ws_value", 0)
	role_prop_node.set("is_ws_state", false)
	hero.tszzs = 0.0
	target.Hp = 100000
	target.SHp = 100000
	target.hd = 0
	target.miss = 0
	target.mdef = 0
	target.Critreduce = 100000
	target.Toughness = 100000
	target.spawn_damage_protection_until_msec = 0
	target.jgz_bl = 1.0
	target.zznh_bl = 1.0
	target.HurtBl = 1.0
	target.lpzzs = 0.0
	target.llrdzs = 1.0
	var hp_before: = int(target.Hp)
	var hit_count_before: = int(global_node.get("TotalHitCount"))
	var role_hit_before: = int(global_node.get("TotalRoleHit"))
	var magic_hit_before: = int(global_node.get("TotalMagHit"))
	hero.PlayerDir = true
	target.velocity = Vector2.ZERO
	var effect = effect_script.new()
	effect.setup(hero, {"id": "probe", "power": 2.0, "kind": "wave"}, "1003900")
	effect.call("_apply_hit", target)
	_check(int(target.Hp) < hp_before, "role3 坐骑技能未对怪物造成伤害")
	_check(hero.HitDic == original_hit_data, "坐骑技能命中后没有恢复人物 HitDic")
	_check(int(role_prop_node.get("ws_value")) == 4, "坐骑技能命中没有积攒无双能量")
	_check(int(global_node.get("TotalHitCount")) == hit_count_before + 1, "坐骑技能命中没有计入总命中次数")
	_check(int(global_node.get("TotalRoleHit")) > role_hit_before, "坐骑技能伤害没有计入人物总伤害")
	_check(int(global_node.get("TotalMagHit")) > magic_hit_before, "坐骑技能伤害没有计入魔法伤害")
	_check(is_equal_approx(target.velocity.x, 8.0) and is_equal_approx(target.velocity.y, -5.0), "坐骑技能击退速度没有与官方 targetMove 一致")
	_check(target.get_target == null, "坐骑技能命中后没有恢复怪物命中来源")
	_check(role_prop_node.get("SourcePlayer") == hero, "坐骑技能命中后没有恢复 SourcePlayer")

	role_prop_node.set("is_ws_state", true)
	var ws_before: = int(role_prop_node.get("ws_value"))
	effect.call("_apply_hit", target)
	_check(int(role_prop_node.get("ws_value")) == ws_before, "无双状态中坐骑命中仍错误积攒能量")
	role_prop_node.set("SourcePlayer", old_source)
	role_prop_node.set("roleprop", old_role_properties)
	role_prop_node.set("baseroleprop", old_base_role_properties)
	role_prop_node.set("ws_up_power", old_ws_up_power)
	global_node.set("TotalRoleHit", old_total_role_hit)
	global_node.set("TotalMagHit", old_total_magic_hit)
	global_node.set("TotalHitCount", old_total_hit_count)
	role_prop_node.set("ws_value", old_ws_value)
	role_prop_node.set("is_ws_state", old_ws_state)
	main_set_data["ShowDamageText"] = old_show_damage_text
	effect.free()
	target.queue_free()
	hero.free()
	if failures.is_empty():
		print("MOUNT_SKILL_EFFECT_PROBE_OK")
	else:
		for failure in failures:
			push_error("MOUNT_SKILL_EFFECT_PROBE_FAIL: %s" % failure)
	quit(0 if failures.is_empty() else 1)

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)
