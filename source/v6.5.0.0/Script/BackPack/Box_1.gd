extends Button
var get_item_name: String
var get_type
var add_equ_box
var sell_box
var qh_level: int
var EQ_prop = {}
var total_number: int
var current_page: int
var gl_po: Vector2
var is_in_ldl_gz = false
var is_in_shop = false
var wx = []
var is_in_hh = false
var is_in_hhgz = false
var get_tt
var HideProp: bool
var ForgeBZID: int
var IsChoose: bool
var MainBack
@onready var item_number: Label = $item_number
var is_in_ldl
var strength_source := "装备背包"
var strength_index := -1
var item_locked := false
@onready var lock_mark: Label = $lock_mark


func _get_strength_max_level(item_name: String) -> int:
	return PlayerData.get_equipment_strength_max_level(EQ_prop, item_name)


func _ready() -> void:
	is_in_ldl = Global.is_in_ldl

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif has_meta("level_fall_box") and str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif icon != null and icon is Texture2D:
		var path_parts = icon.resource_path.split("AllItems/")
		if path_parts.size() > 1:
			get_item_name = str(path_parts[1].split(".")[0])
		else:
			get_item_name = "empty"
	else:
		get_item_name = "empty"


func _physics_process(_delta: float) -> void:
	lock_mark.visible = item_locked and get_item_name != "empty"

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif has_meta("level_fall_box") and str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif icon != null and icon is Texture2D:
		var path_parts = icon.resource_path.split("AllItems/")
		if path_parts.size() > 1:
			get_item_name = str(path_parts[1].split(".")[0])
		else:
			get_item_name = "empty"
	else:
		get_item_name = "empty"

	if add_equ_box != null:
		var popup_parent = add_equ_box.get_parent()
		if popup_parent == null:
			popup_parent = get_parent_()
		gl_po = Global.popup_position_for_parent(popup_parent, Vector2(25, 20))
		add_equ_box.position = gl_po

	is_in_ldl = Global.is_in_ldl

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif get_item_name != "empty":
		if AE.AllEquipment_.has(get_item_name):
			get_type = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
			match get_type:
				"武器":
					item_number.text = ""
				"防具":
					item_number.text = ""
				"饰品", "神骨":
					item_number.text = ""
				"法宝":
					item_number.text = ""
				"翅膀":
					item_number.text = ""
				"时装":
					item_number.text = ""
				"头衔":
					item_number.text = ""
				"道具":
					if total_number > 1:
						item_number.text = str(total_number)
					else:
						item_number.text = ""
				"消耗品":
					if total_number > 1:
						item_number.text = str(total_number)
					else:
						item_number.text = ""
		else:
			get_item_name = "empty"
			total_number = 0
			item_number.text = ""
	else:
		total_number = 0
		item_number.text = ""


func _onPressWhenInBack():
	var parent_ = Global.get_parent_(self, 6)
	var Position_ = Global.popup_position_for_parent(parent_, Vector2(18, 18))
	var number = get_number()
	match get_type:
		"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔", "法宝", "时装", "头衔", "翅膀":
			sell_box = Global.add_se_eq_jm(parent_, Position_, get_item_name, current_page, number)
			_keep_click_menu_near_item(sell_box, parent_)
			sell_box.EQ_prop = EQ_prop
			sell_box.source_box = self
		"消耗品", "道具":
			var pp = Global.add_dj_sell(parent_, Position_, get_item_name, current_page)
			_keep_click_menu_near_item(pp, parent_)
			pp.EQ_prop = EQ_prop
			pp.source_box = self


func _keep_click_menu_near_item(menu: Node, parent_: Node) -> void:
	if menu == null or parent_ == null:
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var estimated_size := Vector2(135, 95)
	if menu is Control:
		estimated_size = (menu as Control).size
		if estimated_size.x <= 0.0 or estimated_size.y <= 0.0:
			estimated_size = Vector2(135, 95)
	var mouse_pos = get_tree().get_root().get_mouse_position()
	var screen_pos = mouse_pos + Vector2(18, 18)
	if screen_pos.x + estimated_size.x > viewport_size.x:
		screen_pos.x = mouse_pos.x - estimated_size.x - 18.0
	if screen_pos.y + estimated_size.y > viewport_size.y:
		screen_pos.y = viewport_size.y - estimated_size.y - 8.0
	if screen_pos.x < 8.0:
		screen_pos.x = 8.0
	if screen_pos.y < 8.0:
		screen_pos.y = 8.0
	var local_pos = screen_pos
	if parent_ is CanvasItem:
		local_pos = (parent_ as CanvasItem).get_global_transform().affine_inverse() * screen_pos
	if menu is Control:
		(menu as Control).position = local_pos
	elif menu is Node2D:
		(menu as Node2D).position = local_pos


func _onPressWhenStrength():
	if bool(EQ_prop.get("不可强化", false)) and get_item_name not in ["cjxianjie", "cdxianjie", "zhxianjie"]:
		var parent_ = Global.get_parent_(self, 7)
		Global.add_message_show(parent_, "该装备不可强化！", 1.5, Vector2(500, 305))
		return
	var get_tt = "宠物装备" if strength_source == "宠物背包" else AE.AllEquipment_[get_item_name][DataKeys.TYPE]
	if get_tt != "道具" and get_tt != "消耗品" and get_tt != "法宝":
		var max_level = _get_strength_max_level(get_item_name)
		if qh_level < max_level:
			MLdl.qh_list[DataKeys.NAME] = get_item_name
			MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
			MLdl.qh_list["页码"] = current_page
			MLdl.qh_list["位置"] = strength_index if strength_index >= 0 else int(str(self.name).split("_")[1]) - 1
			MLdl.qh_list["来源"] = strength_source
			MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
			MLdl.qh_list["Data"] = EQ_prop
		else:
			var parent_ = Global.get_parent_(self, 7)
			Global.add_message_show(parent_, "装备等级已达最高等级！！无法继续强化！", 1.5, Vector2(500, 305))


func _onPressWhenDivineForge() -> void:
	var item_data: Dictionary = AE.AllEquipment_.get(get_item_name, {})
	if (
		bool(EQ_prop.get("不可神铸", item_data.get("不可神铸", false)))
		or item_data.is_empty()
		or not AE.can_divine_forge(get_item_name, EQ_prop)
	):
		var parent_ = Global.get_parent_(self, 7)
		Global.add_message_show(parent_, "只有神器及以上品质的武器、防具和饰品可以神铸！", 1.5, Vector2(500, 305))
		return
	MLdl.qh_list[DataKeys.NAME] = get_item_name
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
	MLdl.qh_list["页码"] = _get_equipment_source_page()
	MLdl.qh_list["位置"] = _get_equipment_source_index()
	MLdl.qh_list["来源"] = strength_source
	MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
	MLdl.qh_list["Data"] = EQ_prop.duplicate(true)


func _onPressWhenBoneForge() -> void:
	var item_data: Dictionary = AE.AllEquipment_.get(get_item_name, {})
	var item_type := str(EQ_prop.get(DataKeys.TYPE, item_data.get(DataKeys.TYPE, "")))
	var next_stage := str(EQ_prop.get("下一阶段", item_data.get("下一阶段", "")))
	if item_data.is_empty() or item_type != "神骨" or next_stage == "":
		var parent_ = Global.get_parent_(self, 7)
		Global.add_message_show(parent_, "只有设置了下一阶段的神骨装备才可以淬骨！", 1.5, Vector2(500, 305))
		return
	MLdl.qh_list[DataKeys.NAME] = get_item_name
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
	MLdl.qh_list["页码"] = _get_equipment_source_page()
	MLdl.qh_list["位置"] = _get_equipment_source_index()
	MLdl.qh_list["来源"] = strength_source
	MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
	MLdl.qh_list["Data"] = EQ_prop.duplicate(true)


func _has_socketed_gems(data: Dictionary) -> bool:
	for key in data.keys():
		if str(key) != "宝石" and str(key) != "��ʯ":
			continue
		var gems = data[key]
		if gems is Array:
			for gem in gems:
				if str(gem) != "":
					return true
		elif gems is Dictionary:
			return gems.size() > 0
		elif gems != null and str(gems) != "":
			return true
	return false


func _onPressWhenSynthesis():
	if strength_source == "人物穿戴":
		var equipped_parent = Global.get_parent_(self, 7)
		Global.add_message_show(equipped_parent, "请先将穿戴中的装备卸下后再进行合成！", 1.5, Vector2(500, 305))
		return

	if not is_in_ldl_gz:
		var parent_ = Global.get_parent_(self, 7)
		for i in PlayerData.player_data["放入列表"]:
			var mylist = PlayerData.player_data["放入列表"][i]
			if mylist.size() == 0:
				var get_tt = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
				if get_tt == "法宝":
					Global.add_message_show(parent_, "法宝无法参与合成！！！", 1.5, Vector2(500, 305))
					return
				if get_tt == "消耗品":
					Global.add_message_show(parent_, "消耗品无法参与合成！！！", 1.5, Vector2(500, 305))
					return
				PlayerData.player_data["放入列表"][i].push_back(str(get_item_name))
				PlayerData.player_data["放入列表"][i].push_back(PlayerData.get_dj_page(get_item_name))
				PlayerData.player_data["放入列表"][i].push_back(int(str(self.name).split("_")[1]) - 1)
				PlayerData.player_data["放入列表"][i].push_back(qh_level)
				PlayerData.player_data["放入列表"][i].push_back(EQ_prop.duplicate(true))
				if (
					get_tt == "武器"
					or get_tt == "防具"
					or get_tt == "饰品"
					or get_tt == "翅膀"
					or get_tt == "时装"
					or get_tt == "头衔"
				):
					if _has_socketed_gems(EQ_prop):
						PlayerData.player_data["放入列表"][i].clear()
						Global.add_message_show(parent_, "请先卸下该装备上的宝石！！！", 1.5, Vector2(500, 305))
						return
					else:
						PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
						Global.get_parent_(self, 6).set_box_data()
				elif get_tt == "道具" or get_tt == "消耗品":
					PlayerData.remove_dj(get_item_name, PlayerData.get_dj_page(get_item_name), 1)
					Global.get_parent_(self, 6).set_box_data()
				elif get_tt == "法宝":
					return
				return
	else:
		var num = str(self.name).split("_")[1]
		if int(num) > 3:
			return
		var list = PlayerData.player_data["放入列表"]["物品" + str(num)]
		if list.has(str(get_item_name)):
			var get_tt = AE.AllEquipment_[list[0]][DataKeys.TYPE]
			if get_tt == "武器" or get_tt == "防具" or get_tt == "饰品" or get_tt == "翅膀" or get_tt == "时装" or get_tt == "头衔":
				PlayerData.add_zb(get_item_name, list[3], EQ_prop)
			elif get_tt == "道具":
				PlayerData.add_dj(list[0], 1)
			elif get_tt == "消耗品":
				PlayerData.add_xhp(list[0], 1)
			elif get_tt == "法宝":
				return
			PlayerData.player_data["放入列表"]["物品" + str(num)].clear()
			MemoryClass.保存游戏(Global.cd_path)
			return


func _onPressWhenDZ():
	if Global.Forge_ == null:
		return
	var item_data: Dictionary = AE.AllEquipment_.get(str(get_item_name), {})
	if item_data.is_empty():
		return
	var Type := str(item_data.get(DataKeys.TYPE, ""))
	var Have := str(item_data.get("所属", ""))
	var item_name := str(item_data.get(DataKeys.NAME, ""))
	if Type == "" or Have == "" or item_name == "":
		Global.add_message_show(Global.get_parent_(self, 7), "物品数据异常，无法参与打造！", 1.5, Vector2(500, 305))
		return
	var parent_ = Global.get_parent_(self, 7)
	if not is_in_ldl_gz:
		if Type != "道具":
			Global.add_message_show(parent_, str(item_name) + "不可以参与打造！", 1.5, Vector2(500, 305))
			return
		if Global.Forge_.zzs.get_children().size() <= 0:
			if Have != "制作书":
				Global.add_message_show(parent_, "只有制作书可以参与打造！", 1.5, Vector2(500, 305))
				return
			else:
				Global.Forge_.replace_book(get_item_name, qh_level, EQ_prop)
		else:
			if Have != "制作书":
				var count_baozhu = 0
				var count_jingshi = 0
				var jewels_value: Variant = PlayerData.player_data.get("宝珠列表", [])
				if not jewels_value is Array:
					Global.add_message_show(parent_, "宝珠数据异常，无法参与打造！", 1.5, Vector2(500, 305))
					return
				for item_value in jewels_value as Array:
					if not item_value is Dictionary:
						continue
					var item: Dictionary = item_value
					var jewel_name := str(item.get(DataKeys.NAME, ""))
					var jewel_data: Variant = AE.AllEquipment_.get(jewel_name, {})
					if not jewel_data is Dictionary:
						continue
					var belong := str((jewel_data as Dictionary).get("所属", ""))
					if belong == "宝珠":
						count_baozhu += 1
					elif belong == "晶石":
						count_jingshi += 1

				if Have == "宝珠" or Have == "晶石":
					if count_baozhu + count_jingshi >= 4:
						Global.add_message_show(parent_, "最多4颗！", 1.5, Vector2(500, 305))
						return
				else:
					Global.add_message_show(parent_, "只能放入宝珠或晶石！", 1.5, Vector2(500, 305))
					return

				var BzProp = {"名字": get_item_name, "强化等级": qh_level, "Data": EQ_prop.duplicate(true)}
				PlayerData.player_data["宝珠列表"].push_back(BzProp)
				Global.Forge_.ADDBZPIC()
				PlayerData.remove_dj(get_item_name, PlayerData.get_dj_page(get_item_name), 1)
				return
			else:
				Global.Forge_.replace_book(get_item_name, qh_level, EQ_prop)
	else:
		Global.Forge_.RemoveBSPIC(ForgeBZID)


func _set_forge_book_box_properties(item_box) -> void:
	if item_box == null or not is_instance_valid(item_box):
		return
	var icon_path := "res://Art/BackPack/AllItems/%s.png" % str(get_item_name)
	item_box.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)
	item_box.set("is_in_ldl_gz", true)
	item_box.set("is_in_hhgz", true)
	item_box.set("qh_level", qh_level)
	item_box.set("total_number", 1)
	item_box.set("wx", [])
	item_box.set("EQ_prop", EQ_prop)
	item_box.set("get_item_name", get_item_name)
	item_box.set_meta("item_name", get_item_name)
	item_box.set("position", Vector2(8, 8))


func _onPressWhenfj():
	if strength_source == "人物穿戴":
		var equipped_parent = Global.get_parent_(self, 7)
		Global.add_message_show(equipped_parent, "穿戴中的装备不能分解，请先卸下！", 1.5, Vector2(500, 305))
		return
	if not is_in_ldl_gz:
		var parent_ = Global.get_parent_(self, 7)
		var get_tt = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
		var Base = AE.AllEquipment_[get_item_name]["所属"]
		var Name_
		if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
			Name_ = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
			var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
			var Data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
			get_tt = AE.AllEquipment_[Name_][DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具":
					PlayerData.add_zb(Name_, cur_level, Data)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
				"道具":
					PlayerData.add_dj(Name_, 1)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
		var get_tt2 = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
		match get_tt2:
			"法宝":
				Global.add_message_show(parent_, "法宝不可以分解！！", 1.5, Vector2(500, 305))
				return
			"消耗品":
				Global.add_message_show(parent_, "消耗品不可以分解！！", 1.5, Vector2(500, 305))
				return
			"翅膀":
				Global.add_message_show(parent_, "翅膀无不可以分解！！", 1.5, Vector2(500, 305))
				return
			"时装":
				Global.add_message_show(parent_, "时装不可以分解！！", 1.5, Vector2(500, 305))
				return
			"头衔":
				Global.add_message_show(parent_, "头衔不可以分解！！", 1.5, Vector2(500, 305))
				return
			"道具":
				PlayerData.player_data[DataKeys.DECOMPOSE_LIST].push_back(
					{"名字": get_item_name, "强化等级": qh_level, "Data": EQ_prop.duplicate(true)}
				)
				PlayerData.remove_dj(get_item_name, current_page, 1)
			"武器", "防具", "饰品", "翅膀", "时装", "头衔":
				if _has_socketed_gems(EQ_prop):
					Global.add_message_show(parent_, "请先卸下该装备上的宝石！！！", 1.5, Vector2(500, 305))
					return
				PlayerData.player_data[DataKeys.DECOMPOSE_LIST].push_back(
					{"名字": get_item_name, "强化等级": qh_level, "Data": EQ_prop.duplicate(true)}
				)
				PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
			"":
				Global.add_message_show(parent_, "错误？？！！", 1.5, Vector2(500, 305))
				return
	else:
		if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
			var Name_ = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
			var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
			var Data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
			get_tt = AE.AllEquipment_[Name_][DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具":
					PlayerData.add_zb(Name_, cur_level, Data)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
				"道具":
					PlayerData.add_dj(Name_, 1)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
		return


func _onPressWhenXQ():
	if not is_in_ldl_gz:
		var parent_ = Global.get_parent_(self, 7)
		if strength_source == "宠物背包":
			if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
				Global.add_message_show(parent_, "请先将镶嵌格子内装备卸下！！", 1.5, Vector2(500, 305))
				return
			if not PlayerData.take_pet_equipment_for_mosaic(strength_index, EQ_prop, get_item_name):
				Global.add_message_show(parent_, "宠物装备位置已变化，请重新选择！！", 1.5, Vector2(500, 305))
			return
		var get_tt = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
		var Base = AE.AllEquipment_[get_item_name]["所属"]
		if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
			match get_tt:
				"法宝":
					Global.add_message_show(parent_, "法宝不可以镶嵌宝石！！", 1.5, Vector2(500, 305))
					return
				"消耗品":
					Global.add_message_show(parent_, "不可放入消耗品！！", 1.5, Vector2(500, 305))
					return

				"道具":
					if Base == "宝石":
						if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
							Global.add_message_show(parent_, "请先放入装备！！", 1.5, Vector2(500, 305))
					else:
						Global.add_message_show(parent_, "该道具不可用于镶嵌！！", 1.5, Vector2(500, 305))

				"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔":
					if strength_source == "人物穿戴":
						var equipped_slot := str(get_meta("equipped_type", ""))
						var taken_equipment: Dictionary = PlayerData.take_equipped_equipment_for_mosaic(
							equipped_slot, get_item_name, EQ_prop
						)
						if taken_equipment.is_empty():
							Global.add_message_show(parent_, "穿戴装备位置已变化，请重新选择！", 1.5, Vector2(500, 305))
							return
					else:
						PlayerData.player_data[DataKeys.INLAY_LIST].push_back(
							{"名字": get_item_name, "强化等级": qh_level, "Data": EQ_prop.duplicate(true)}
						)
						PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
					Global.get_parent_(self, 6).set_box_data()

				"":
					Global.add_message_show(parent_, "错误？？！！", 1.5, Vector2(500, 305))
					return
		else:
			var Data = PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"]
			match get_tt:
				"法宝":
					Global.add_message_show(parent_, "法宝不可以镶嵌宝石！！", 1.5, Vector2(500, 305))
					return
				"消耗品":
					Global.add_message_show(parent_, "不可放入消耗品！！", 1.5, Vector2(500, 305))
					return
				"道具":
					if Base == "宝石":
						if Data[DataKeys.GEM].size() < get_MaxBs():
							if Data[DataKeys.GEM].size() != 0:
								PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].push_back(
									get_item_name
								)
								PlayerData.remove_dj(get_item_name, current_page, 1)
							else:
								PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].push_back(
									get_item_name
								)
								PlayerData.remove_dj(get_item_name, current_page, 1)

						else:
							Global.add_message_show(
								parent_, "最多镶嵌" + str(get_MaxBs()) + "个宝石！！", 1.5, Vector2(500, 305)
							)
							return
					else:
						Global.add_message_show(parent_, "该道具不可用于镶嵌！！", 1.5, Vector2(500, 305))
						return
				"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔":
					Global.add_message_show(parent_, "请先将镶嵌格子内装备卸下！！", 1.5, Vector2(500, 305))
					return
				"":
					Global.add_message_show(parent_, "错误？？！！", 1.5, Vector2(500, 305))
					return
	else:
		if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
			if strength_source == "宠物背包":
				PlayerData.restore_mosaic_equipment()
				return
			var get_tt = AE.AllEquipment_[get_item_name][DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具", "神骨", "翅膀", "时装", "头衔":
					PlayerData.restore_mosaic_equipment()
				"道具":
					PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].erase(get_item_name)
					PlayerData.add_dj(get_item_name, 1)
				"":
					pass
		return


func _on_pressed() -> void:
	var parent_
	if Global.BoxCount > 0:
		if is_in_ldl:
			parent_ = Global.get_parent_(self, 7)
		else:
			parent_ = Global.get_parent_(self, 6)
		if is_in_hh or is_in_shop or is_in_hhgz:
			return
		else:
			Global.add_message_show(parent_, "点击过快！！", 1.5, Vector2(500, 305))
		return
	else:
		Global.BoxCount = 6
	if HideProp:
		return
	if is_in_hh or is_in_shop or is_in_hhgz:
		return
	if add_equ_box != null:
		add_equ_box.queue_free()
	if get_item_name != "empty" and sell_box == null:
		if Global.is_in_ldl == false:
			_onPressWhenInBack()
		elif Global.is_in_ldl == true:
			match MLdl.loc_:
				"强化":
					_onPressWhenStrength()
				"神铸":
					_onPressWhenDivineForge()
				"淬骨":
					_onPressWhenBoneForge()
				"合成":
					_onPressWhenSynthesis()
				"镶嵌":
					_onPressWhenXQ()
				"分解":
					Global.NeedChangeItem = true
					_onPressWhenfj()
				"打造":
					_onPressWhenDZ()
	MemoryClass.保存游戏(Global.cd_path)


func _on_mouse_entered() -> void:
	if HideProp:
		return
	if get_item_name != "empty" and add_equ_box == null:
		var tt = get_parent_()
		var pp = Global.popup_position_for_parent(tt, Vector2(25, 20))
		if EQ_prop != null:
			add_equ_box = Global.add_equ_propeties_box(tt, pp, get_item_name, qh_level, wx, EQ_prop)
			if strength_source == "宠物背包" and add_equ_box.has_method("setup_pet_equipment"):
				add_equ_box.call("setup_pet_equipment", EQ_prop)
			add_equ_box.is_in_ldl_gz = is_in_ldl_gz
			add_equ_box.is_in_shop = is_in_shop


func _on_mouse_exited() -> void:
	if add_equ_box != null:
		add_equ_box.queue_free()


func get_number():
	var number = int(str(self.name).split("_")[1]) - 1
	return number


func _get_equipment_source_page() -> int:
	var source_page := int(get_meta("backpack_page", 0))
	return source_page if source_page > 0 else int(current_page)


func _get_equipment_source_index() -> int:
	var source_index := int(get_meta("backpack_index", -1))
	return source_index if source_index >= 0 else get_number()


func get_parent_():
	var LastParent
	if is_in_hh or is_in_hhgz or is_in_shop or is_in_ldl_gz or is_in_ldl:
		LastParent = Global.Windows_
	else:
		LastParent = Global.get_parent_(self, 7)
	return LastParent


func get_MaxBs():
	if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
		return 0
	return 8


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc
