extends SceneTree

const MOUNT_CATALOG: = preload("res://Script/Mount/MountCatalog.gd")

var failures: Array[String] = []

func _initialize() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		failures.append(message)

func _run() -> void :
	var player_data_node: = root.get_node_or_null("PlayerData")
	var equipment_data_node: = root.get_node_or_null("AE")
	_check(player_data_node != null, "PlayerData Autoload 未加载")
	_check(equipment_data_node != null, "AE Autoload 未加载")
	if player_data_node == null or equipment_data_node == null:
		quit(1)
		return
	var all_equipment_value: Variant = equipment_data_node.get("AllEquipment_")
	var all_equipment: Dictionary = all_equipment_value if all_equipment_value is Dictionary else {}
	var original: Dictionary = player_data_node.player_data.duplicate(true)
	player_data_node.player_data["玩家等级"] = 10
	player_data_node.player_data["通天教主"] = 0
	_check( not bool(player_data_node.call("is_mount_system_unlocked")), "未通关碧游宫时坐骑系统错误开放")
	player_data_node.player_data.erase("坐骑列表")
	player_data_node.player_data.erase("出战坐骑")
	var mounts: Array = player_data_node.call("ensure_mount_data")
	_check(mounts.size() == 7, "坐骑列表没有初始化七只原版坐骑")
	var expected_unlock_items: = {
		"1002200": "139300016", "1002700": "139300018", 
		"1002800": "139300017", "1003500": "139300014V1", 
		"1003600": "139300012", "1004700": "139300021", 
	}
	for mount_id_value in expected_unlock_items.keys():
		var mount_id: = str(mount_id_value)
		var item_id: = str(expected_unlock_items[mount_id])
		var requirement: Dictionary = player_data_node.call("get_mount_unlock_requirement", mount_id)
		var locked_mount: Dictionary = player_data_node.call("get_mount_by_id", mount_id)
		_check(str(requirement.get("物品", "")) == item_id, "坐骑%s解锁材料映射错误" % mount_id)
		_check( not bool(locked_mount.get(player_data_node.MOUNT_UNLOCKED_KEY, true)), "坐骑%s没有默认锁定" % mount_id)
		_check(all_equipment.has(item_id), "坐骑解锁材料%s没有加入物品库" % item_id)
		_check(ResourceLoader.exists("res://Art/BackPack/AllItems/%s.png" % item_id), "坐骑解锁材料%s缺少图标" % item_id)
	var sacred_tiger: = player_data_node.call("get_mount_by_id", "1002200") as Dictionary
	_check(str(sacred_tiger.get("名称", "")) == "西灵圣虎", "坐骑1002200名称没有迁移为西灵圣虎")
	_check( not bool(sacred_tiger.get(player_data_node.MOUNT_UNLOCKED_KEY, true)), "西灵圣虎没有默认锁定")
	_check( not bool(player_data_node.call("set_active_mount", "1002200")), "未解锁的西灵圣虎仍可出战")
	_check( not bool(player_data_node.call("unlock_mount", "1002200")), "没有战神虎爪时仍能解锁西灵圣虎")
	player_data_node.call("add_dj", "139300016", 1)
	_check(int(player_data_node.call("get_inventory_item_count", "139300016")) == 1, "战神虎爪没有正确加入背包")
	_check(bool(player_data_node.call("unlock_mount", "1002200")), "消耗战神虎爪后未能解锁西灵圣虎")
	_check(int(player_data_node.call("get_inventory_item_count", "139300016")) == 0, "解锁西灵圣虎后没有扣除战神虎爪")
	sacred_tiger["等级"] = 10
	sacred_tiger["经验"] = 999999
	player_data_node.call("add_mount_exp", "1002200", 1)
	_check(int(sacred_tiger.get("等级", 0)) == 10, "坐骑等级超过了人物当前等级")
	_check(int(sacred_tiger.get("经验", -1)) == 0, "达到人物等级上限后仍保留溢出经验")
	_check(bool(player_data_node.call("set_active_mount", "1003900")), "远古年兽无法设置出战")
	var active_mount: Dictionary = player_data_node.call("get_active_mount")
	_check(str(active_mount.get("名称", "")) == "远古年兽", "出战坐骑读取错误")
	_check( not bool(player_data_node.call("set_mount_riding", true)), "未通关碧游宫时仍可骑乘")
	_check((player_data_node.call("get_active_mount_attribute_bonuses") as Dictionary).is_empty(), "未通关碧游宫时仍获得坐骑属性")
	player_data_node.player_data["通天教主"] = 1
	_check(bool(player_data_node.call("is_mount_system_unlocked")), "通关碧游宫后坐骑系统没有开放")
	_check(bool(player_data_node.call("set_mount_riding", true)), "有疲劳时无法骑乘")
	var before_level: = int(active_mount.get("等级", 1))
	var needed_exp: = int(player_data_node.call("mount_exp_for_level", before_level))
	player_data_node.call("add_mount_exp", "1003900", needed_exp)
	active_mount = player_data_node.call("get_active_mount")
	_check(int(active_mount.get("等级", 1)) == before_level + 1, "坐骑升级失败")
	player_data_node.player_data["玩家等级"] = 11
	sacred_tiger["经验"] = 0
	player_data_node.call("add_mount_exp", "1002200", int(player_data_node.call("mount_exp_for_level", 10)))
	_check(int(sacred_tiger.get("等级", 0)) == 11, "人物升级后坐骑无法继续升级")
	var bonuses: Dictionary = player_data_node.call("get_active_mount_attribute_bonuses")
	active_mount = player_data_node.call("get_active_mount")
	_check(int(bonuses.get("SHp", 0)) == int(active_mount.get("生命", 0)), "出战坐骑生命被重复放大")
	_check(int(bonuses.get("power", 0)) == int(active_mount.get("攻击", 0)), "出战坐骑攻击被重复放大")
	_check(int(bonuses.get("Def", 0)) == int(active_mount.get("物防", 0)), "出战坐骑物防被重复放大")
	_check(int(bonuses.get("Mdef", 0)) == int(active_mount.get("魔防", 0)), "出战坐骑魔防被重复放大")
	var panel_scene: = load("res://Scene/Main_menu/MountPanel.tscn") as PackedScene
	_check(panel_scene != null, "坐骑页面无法加载")
	_verify_official_movement_data()
	player_data_node.player_data = original
	if failures.is_empty():
		print("MOUNT_SYSTEM_PROBE_OK")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)

func _verify_official_movement_data() -> void :
	var nian_charge: = MOUNT_CATALOG.get_official_movement("3104200")
	_check(is_equal_approx(float(nian_charge.get("start", 0.0)), 21.0 / 30.0), "屠戮之角没有在官方21帧开始冲刺")
	_check(is_equal_approx(float(nian_charge.get("speed", 0.0)), 300.0), "屠戮之角冲刺速度不是官方300")
	var tiger_charge: = MOUNT_CATALOG.get_official_movement("3106900")
	_check(is_equal_approx(float(tiger_charge.get("start", 0.0)), 11.0 / 30.0), "横扫千军没有在官方11帧开始冲刺")
	_check(is_equal_approx(float(tiger_charge.get("duration", 0.0)), 0.6), "横扫千军冲刺时长不是官方600毫秒")
	_check( not bool(tiger_charge.get("stop_on_hit", false)), "横扫千军被错误套用了独立弹幕的命中停止规则")
	var dragon_fish_charge: = MOUNT_CATALOG.get_official_movement("3106000")
	_check(is_equal_approx(float(dragon_fish_charge.get("start", 0.0)), 1.0 / 30.0), "鱼龙九变没有在官方第1帧开始冲刺")
	_check(is_equal_approx(float(dragon_fish_charge.get("duration", 0.0)), 27.0 / 30.0), "鱼龙九变没有在动作结束后解除方向锁定")
	_check( not bool(dragon_fish_charge.get("stop_on_hit", false)), "鱼龙九变被错误改成命中停止")
	var fish_boost: = MOUNT_CATALOG.get_official_movement("3107300")
	_check(is_equal_approx(float(fish_boost.get("multiplier", 0.0)), 1.8), "流光飞舞没有应用官方80%移速增益")
	_check(MOUNT_CATALOG.get_official_movement("3105300").is_empty(), "飞龙在天被错误附加角色强制位移")
	_check(MOUNT_CATALOG.get_official_movement("3107500").is_empty(), "神鹿撞击被错误附加角色强制位移")
	var dragon_dash: = MOUNT_CATALOG.get_official_movement("3110900")
	_check(is_equal_approx(float(dragon_dash.get("start", 0.0)), 11.0 / 30.0), "汲魄龙威没有在官方11帧开始冲刺")
	_check(is_equal_approx(float(dragon_dash.get("speed", 0.0)), 800.0), "汲魄龙威冲刺速度不是官方800")
	_check(is_equal_approx(MOUNT_CATALOG.to_runtime_knockback_x(240), 8.0), "官方横向击退值没有换算到项目受击速度单位")
	_check(is_equal_approx(MOUNT_CATALOG.to_runtime_knockback_y(-60), -4.0), "官方纵向击退值没有换算到项目受击速度单位")
