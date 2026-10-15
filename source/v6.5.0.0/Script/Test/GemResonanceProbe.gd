extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run")

func _check(condition: bool, message: String) -> void :
	if not condition:
		_failed = true
		push_error("GEM_RESONANCE_FAIL: " + message)

func _gems(level: int) -> Array:
	var result: Array = []
	for prefix in ["sms", "mfs", "gjs", "fys", "mks", "bjs", "sbs", "hxs"]:
		var gem_id: = "%s_%d" % [prefix, level]

		if not AE.AllEquipment_.has(gem_id):
			gem_id = "sms_%d" % level
		result.append(gem_id)
	return result

func _run() -> void :
	var original_data: = PlayerData.player_data.duplicate(true)
	var original_path: String = Global.cd_path
	Global.cd_path = ""
	var item_id: = "zxstg"
	var data: Dictionary = AE.AllEquipment_[item_id].duplicate(true)
	var unchanged: = data.duplicate(true)
	_check(AE.get_gem_resonance_level({}) == 0, "旧数据缺少宝石字段")
	_check(AE.get_gem_resonance_level({"宝石": {}}) == 0, "旧数据异常宝石字段")
	for level in range(1, 8):
		data["宝石"] = _gems(level)
		_check(AE.get_gem_resonance_level(data) == level, "共鸣等级错误")
		_check(is_equal_approx(float(AE.scale_gem_resonance_value(100, data)), 100.0 + level * 15), "每级加成应为15%")
	data["宝石"] = _gems(7)
	data["宝石"][3] = "sms_2"
	_check(AE.get_gem_resonance_level(data) == 2, "混合等级未取最低等级")
	var raw_hp: = 0.0
	for gem_id in data["宝石"]:
		raw_hp += float(AE.AllEquipment_[gem_id].get("SHp", 0))
	data["神铸阶段"] = 5
	var bonus: Dictionary = AE.get_divine_forge_gem_properties(item_id, data)
	_check(is_equal_approx(float(bonus.SHp), raw_hp * 1.3), "共鸣加成错误或叠加了神铸")
	var base: Dictionary = AE.get_divine_forge_properties(item_id, 3, data)
	var total: Dictionary = AE.get_divine_forge_properties(item_id, 3, data, true)
	_check(is_equal_approx(float(total.SHp), float(base.SHp) + float(bonus.SHp)), "含宝石总属性重复放大神铸")
	_check(float(base.power) > float(data.power), "装备本身神铸加成丢失")
	data["神铸阶段"] = 0
	_check(AE.get_divine_forge_gem_properties(item_id, data) == bonus, "宝石属性仍受神铸阶段影响")
	data["宝石"].pop_back()
	_check(AE.get_gem_resonance_level(data) == 0, "不足8颗应关闭共鸣")
	_check(AE.scale_gem_resonance_value(100, data) == 100, "不足8颗仍有共鸣加成")
	data["神铸阶段"] = 5
	raw_hp = 0
	for gem_id in data["宝石"]:
		raw_hp += float(AE.AllEquipment_[gem_id].get("SHp", 0))
	_check(is_equal_approx(float(AE.get_divine_forge_gem_properties(item_id, data).SHp), raw_hp), "未共鸣宝石仍受神铸加成")
	data["宝石"] = _gems(2)
	data["宝石"][0] = "empty"
	_check(AE.get_gem_resonance_level(data) == 0, "无效宝石触发共鸣")
	data["宝石"] = _gems(2)
	for row in [["武器", "get_BsWqProperies", "WqBs_prop"], ["防具", "get_BsFjProperies", "FjBs_prop"], ["饰品", "get_BsSpProperies", "SpBs_prop"], ["翅膀", "get_BsCbProperies", "CbBs_prop"], ["时装", "get_BsSzProperies", "SzBs_prop"], ["头衔", "get_BsTxProperies", "TxBs_prop"]]:
		PlayerData.player_data[row[0]] = [{"名字": item_id, "Data": data}]
		RoleProp.call(row[1])
		_check(RoleProp.get(row[2]) == AE.get_divine_forge_gem_properties(item_id, data), "角色槽位宝石计算不一致：" + row[0])
		PlayerData.player_data[row[0]] = []
		RoleProp.call(row[1])
		_check(float(RoleProp.get(row[2]).SHp) == 0, "卸装未清除共鸣：" + row[0])
	_check(AE.AllEquipment_[item_id] == unchanged, "共鸣修改了装备模板")
	var popup = load("res://Scene/BackPack/equipment_properies.tscn").instantiate()
	popup.nam = item_id
	popup.EQ_prop = data.duplicate(true)
	popup.qh_level = 3
	popup.position = Vector2(180, 40)
	add_child(popup)
	await get_tree().create_timer(0.4).timeout
	var label: Label = popup.BsProList.get_parent().get_node("GemResonance")
	_check(label.get_index() == popup.BsProList.get_index() - 1, "共鸣说明未放在宝石列表上方")
	_check(label.text.contains("2级") and label.text.contains("+30%"), "装备信息框共鸣显示错误")
	_check(popup.set_BsProp() == AE.get_divine_forge_gem_properties(item_id, data), "信息框宝石属性与角色不一致")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot: = ProjectSettings.globalize_path("user://gem_resonance_tooltip.png")
		_check(get_viewport().get_texture().get_image().save_png(screenshot) == OK, "信息框截图失败")
		print("GEM_RESONANCE_SCREENSHOT=" + screenshot)
	popup.EQ_prop["宝石"].pop_back()
	popup.setBsInfor()
	_check(label.text.contains("未开启") and label.text.contains("7/8"), "移除宝石未更新共鸣说明")
	popup.queue_free()
	var magic = load("res://Scene/BackPack/equipment_properies.tscn").instantiate()
	magic.nam = "469000011"
	magic.EQ_prop = AE.AllEquipment_[magic.nam].duplicate(true)
	magic.EQ_prop["宝石"] = _gems(2)
	magic.qh_level = 15
	magic.wx = ["金", "木", "水", "火", "土"]
	magic.position = Vector2(180, 40)
	add_child(magic)
	await get_tree().create_timer(0.4).timeout
	_check(AE.get_gem_resonance_level(magic.EQ_prop) == 0, "法宝仍能触发共鸣")
	_check(magic.BsProList.get_parent().get_node_or_null("GemResonance") == null, "法宝信息框仍显示宝石共鸣")
	_check( not magic.BsProList.visible, "法宝信息框仍显示宝石列表")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var screenshot: = ProjectSettings.globalize_path("user://magic_weapon_no_resonance.png")
		_check(get_viewport().get_texture().get_image().save_png(screenshot) == OK, "法宝信息框截图失败")
	magic.queue_free()
	PlayerData.player_data = original_data
	RoleProp.get_equ_last_pro()
	Global.cd_path = original_path
	print("GEM_RESONANCE_PROBE_OK" if not _failed else "GEM_RESONANCE_PROBE_FAILED")
	get_tree().quit(1 if _failed else 0)
