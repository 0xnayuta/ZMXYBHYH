extends Node2D
class_name Mosaic
@onready var bs_1: Button = $bs_1/bs_1
@onready var bs_2: Button = $bs_2/bs_2
@onready var bs_3: Button = $bs_3/bs_3
@onready var bs_4: Button = $bs_4/bs_4

@onready var bs_5: Button = $bs_5/bs_5
@onready var bs_6: Button = $bs_6/bs_6
@onready var bs_7: Button = $bs_7/bs_7
@onready var bs_8: Button = $bs_8/bs_8
@onready var Zb: Button = $zb/Zb

const PET_GENERIC_EQUIPMENT_ICON := preload("res://Art/Pet/PetPageResources/PetInterfacev1270_id267_jpeg3_64x64.png")


func _physics_process(_delta: float) -> void:
	setBoxInLdL()

	if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
		set_ZBProperies()
		set_OtherProp()
	else:
		remove_infomation()


func setBoxInLdL():
	bs_1.is_in_ldl_gz = true
	bs_2.is_in_ldl_gz = true
	bs_3.is_in_ldl_gz = true
	bs_4.is_in_ldl_gz = true
	Zb.is_in_ldl_gz = true

	bs_5.is_in_ldl_gz = true
	bs_6.is_in_ldl_gz = true
	bs_7.is_in_ldl_gz = true
	bs_8.is_in_ldl_gz = true


func set_ZBProperies():
	var selected: Dictionary = PlayerData.player_data[DataKeys.INLAY_LIST][0]
	Zb.qh_level = int(selected[DataKeys.ENHANCE_LEVEL])
	Zb.get_item_name = str(selected[DataKeys.NAME])
	Zb.strength_source = str(selected.get("来源", "装备背包"))
	Zb.strength_index = int(selected.get("位置", -1))
	Zb.set_meta("equipped_type", str(selected.get("穿戴栏", "")))
	if Zb.strength_source == "宠物背包" and selected.get("宠物装备", {}) is Dictionary:
		var pet_item: Dictionary = selected["宠物装备"]
		Zb.set_button_icon(_pet_item_icon(pet_item, Zb.get_item_name))
		Zb.EQ_prop = pet_item
	else:
		Zb.set_button_icon(load_(Zb.get_item_name))
		Zb.EQ_prop = selected["Data"]


func set_OtherProp():
	var BSsize = PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].size()
	var bs_list = [bs_1, bs_2, bs_3, bs_4, bs_5, bs_6, bs_7, bs_8]
	for i in range(bs_list.size()):
		if i < BSsize:
			bs_list[i].set_button_icon(
				load_(str(PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM][i]))
			)
		else:
			bs_list[i].set_button_icon(load_(str("empty")))


func remove_infomation():
	PlayerData.restore_mosaic_equipment()
	Zb.set_button_icon(load_(str("empty")))
	Zb.get_item_name = "empty"
	Zb.qh_level = 0
	Zb.EQ_prop = {}
	Zb.strength_source = "装备背包"
	Zb.strength_index = -1
	Zb.set_meta("equipped_type", "")
	bs_1.set_button_icon(load_(str("empty")))
	bs_2.set_button_icon(load_(str("empty")))
	bs_3.set_button_icon(load_(str("empty")))
	bs_4.set_button_icon(load_(str("empty")))

	bs_5.set_button_icon(load_(str("empty")))
	bs_6.set_button_icon(load_(str("empty")))
	bs_7.set_button_icon(load_(str("empty")))
	bs_8.set_button_icon(load_(str("empty")))
	PlayerData.player_data[DataKeys.INLAY_LIST].clear()


func _pet_item_icon(item: Dictionary, item_id: String) -> Texture2D:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, data]:
		for key in ["图标", "图标路径", "icon", "Icon"]:
			var icon_path := str(source.get(key, "")).strip_edges()
			if icon_path == "":
				continue
			if not icon_path.begins_with("res://"):
				icon_path = "res://Art/BackPack/AllItems/" + icon_path
				if icon_path.get_extension() == "":
					icon_path += ".png"
			if ResourceLoader.exists(icon_path):
				return load(icon_path) as Texture2D
	var item_path := "res://Art/BackPack/AllItems/%s.png" % item_id
	if ResourceLoader.exists(item_path):
		return load(item_path) as Texture2D
	return PET_GENERIC_EQUIPMENT_ICON


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc


func _on_help_pressed() -> void:
	Global.AddMosaicHelp(Global.get_parent_(self, 3), Vector2(0, 0))
