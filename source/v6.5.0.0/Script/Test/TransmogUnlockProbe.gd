extends Node

var _failed: = false

func _ready() -> void :
	call_deferred("_run_probe")

func _run_probe() -> void :
	var original: Dictionary = PlayerData.player_data.duplicate(true)
	var original_path: String = Global.cd_path
	var original_windows = Global.Windows_
	Global.cd_path = ""
	Global.Windows_ = self
	PlayerData.player_data["Myself"] = 3
	for page in PlayerData.player_data["装备列表"]:
		PlayerData.player_data["装备列表"][page] = []
	for slot in ["武器", "防具", "时装", "翅膀", "头衔"]:
		PlayerData.player_data[slot] = []
	PlayerData.player_data["幻化拥有列表"] = []
	PlayerData.player_data["幻化列表"] = {"武器": "", "防具": "", "时装": "", "翅膀": "", "头衔": ""}
	PlayerData.player_data.erase("已获取装备列表")

	_check( not PlayerData.has_acquired_equipment("sllyp"), "未获取的装备被解锁")
	_check(PlayerData.add_zb("sllyp", 0, {}), "释罗武器获取失败")
	_check(PlayerData.add_zb("sllyp", 0, {}), "重复获取失败")
	_check(PlayerData.player_data["已获取装备列表"].count("sllyp") == 1, "解锁记录重复")
	PlayerData.remove_zb(1, 0)
	PlayerData.remove_zb(1, 0)
	_check(PlayerData.check_zb("sllyp").is_empty(), "武器未移出背包")
	_check(PlayerData.has_acquired_equipment("sllyp"), "未打开幻化界面就出售丢失解锁")
	_check(PlayerData.add_zb("slfk", 0, {}), "释罗防具获取失败")
	PlayerData.remove_zb(1, 0)
	_check(PlayerData.has_acquired_equipment("slfk"), "防具出售后丢失解锁")
	PlayerData.record_acquired_equipment("slfkzzs")
	_check( not PlayerData.has_acquired_equipment("slfkzzs"), "制作书被当作装备解锁")

	var save_data: Dictionary = MemoryClass._prepare_player_save_data()
	_check( not save_data.is_empty(), "保存数据准备失败")
	PlayerData.player_data = bytes_to_var(var_to_bytes(save_data))
	_check(PlayerData.has_acquired_equipment("sllyp") and PlayerData.has_acquired_equipment("slfk"), "保存数据往返后解锁丢失")

	PlayerData.player_data.erase("已获取装备列表")
	PlayerData.player_data["装备列表"]["页码1"] = [{"名字": "sllyp", "强化等级": 0, "Data": AE.AllEquipment_["sllyp"].duplicate(true)}]
	PlayerData.player_data["防具"] = [{"名字": "slfk", "强化等级": 0, "Data": AE.AllEquipment_["slfk"].duplicate(true)}]
	PlayerData.player_data["幻化拥有列表"] = ["ptdp"]
	PlayerData.player_data["幻化列表"]["武器"] = "jcjp"
	PlayerData.ensure_acquired_equipment_data()
	for item_id in ["sllyp", "slfk", "ptdp", "jcjp"]:
		_check(PlayerData.has_acquired_equipment(item_id), "旧存档解锁兼容失败：" + item_id)
	PlayerData.player_data = save_data.duplicate(true)

	var page = load("res://Scene/OtherScene/Transmogrified.tscn").instantiate()
	add_child(page)
	await get_tree().process_frame
	await get_tree().physics_frame
	_check(page.RoleItemList["八戒"].has("sllyp") and page.RoleItemList["八戒"].has("slfk"), "八戒释罗装备未加入幻化列表")
	_check(PlayerData.player_data["幻化拥有列表"].has("sllyp") and PlayerData.player_data["幻化拥有列表"].has("slfk"), "出售后的装备未进入幻化收集列表")
	for item_id in ["sllyp", "slfk"]:
		var ids: Array = page.GetCurrentRoleList()
		page.currentpage = int(ids.find(item_id) / 6) + 1
		page.AddBox()
		await get_tree().process_frame
		await get_tree().physics_frame
		var found: = false
		for box in page.box_list.get_children():
			if box.is_queued_for_deletion() or box.SelfName_ != item_id:
				continue
			found = true
			_check(box.AlreadyHave(item_id), "出售后幻化卡片未解锁")
			box._on_change_pressed()
			await get_tree().physics_frame
			_check(PlayerData.player_data["幻化列表"][AE.AllEquipment_[item_id]["类型"]] == item_id, "出售后无法点击幻化")
		_check(found, "未找到释罗幻化卡片")
	_check(page.role_equipment.texture.resource_path.ends_with("Role_3_Eq_sllyp.png"), "释罗武器预览贴图错误")
	_check(page.role_body.texture.resource_path.ends_with("Role_3_Body_slfk.png"), "释罗防具预览贴图错误")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		var path: = ProjectSettings.globalize_path("user://transmog_unlock_probe.png")
		_check(get_viewport().get_texture().get_image().save_png(path) == OK, "截图保存失败")
		print("TRANSMOG_UNLOCK_SCREENSHOT=" + path)
	page.queue_free()
	PlayerData.player_data = original
	Global.cd_path = original_path
	Global.Windows_ = original_windows
	print("TRANSMOG_UNLOCK_PROBE_OK" if not _failed else "TRANSMOG_UNLOCK_PROBE_FAILED")
	get_tree().quit(1 if _failed else 0)

func _check(condition: bool, message: String) -> void :
	if not condition:
		push_error(message)
		_failed = true
