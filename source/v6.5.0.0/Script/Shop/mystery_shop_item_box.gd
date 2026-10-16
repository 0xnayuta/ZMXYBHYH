extends TextureRect
var _item_hover_inside := false
@onready var ItemBox: Button = $ItemBox
var _item_hover_popup
@onready var ItemNum: Label = $Num
@onready var NeedValue: Label = $Need
@onready var PurchaseButton: Button = $Purchase
var AllItemList = {
	"Box_1":
	[
		{"Name": "xuantie", "Value": 5, "WX": [], "Level": 0, "Need": 500},
		{"Name": "sichou", "Value": 5, "WX": [], "Level": 0, "Need": 500},
		{"Name": "tanmu", "Value": 5, "WX": [], "Level": 0, "Need": 500}
	],
	"Box_2":
	[
		{"Name": "xuantie", "Value": 10, "WX": [], "Level": 0, "Need": 1000},
		{"Name": "sichou", "Value": 5, "WX": [], "Level": 0, "Need": 1000},
		{"Name": "tanmu", "Value": 10, "WX": [], "Level": 0, "Need": 1000}
	],
	"Box_3":
	[
		{"Name": "xuantie", "Value": 20, "WX": [], "Level": 0, "Need": 2000},
		{"Name": "sichou", "Value": 20, "WX": [], "Level": 0, "Need": 2000},
		{"Name": "tanmu", "Value": 20, "WX": [], "Level": 0, "Need": 2000}
	],
	"Box_4":
	[
		{"Name": "bsd_1", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "bsd_2", "Value": 1, "WX": [], "Level": 0, "Need": 120000},
		{"Name": "qhs_1", "Value": 1, "WX": [], "Level": 0, "Need": 3000},
		{"Name": "qhs_2", "Value": 1, "WX": [], "Level": 0, "Need": 8000},
		{"Name": "qhs_3", "Value": 1, "WX": [], "Level": 0, "Need": 22000},
		{"Name": "qhs_4", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "sms_1", "Value": 1, "WX": [], "Level": 0, "Need": 15000},
		{"Name": "sms_2", "Value": 1, "WX": [], "Level": 0, "Need": 40000},
		{"Name": "fls_1", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "fls_2", "Value": 1, "WX": [], "Level": 0, "Need": 54000},
		{"Name": "gjs_1", "Value": 1, "WX": [], "Level": 0, "Need": 18000},
		{"Name": "gjs_2", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "wfs_1", "Value": 1, "WX": [], "Level": 0, "Need": 12000},
		{"Name": "wfs_2", "Value": 1, "WX": [], "Level": 0, "Need": 32000},
		{"Name": "mfs_1", "Value": 1, "WX": [], "Level": 0, "Need": 12000},
		{"Name": "mfs_2", "Value": 1, "WX": [], "Level": 0, "Need": 32000},
		{"Name": "hxs_1", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "hxs_2", "Value": 1, "WX": [], "Level": 0, "Need": 54000},
		{"Name": "mpyj", "Value": 1, "WX": [], "Level": 0, "Need": 3000},
		{"Name": "yll", "Value": 1, "WX": [], "Level": 0, "Need": 4000},
		{"Name": "renshen", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "shougong", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "lingli", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "liuhuang", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "leizong", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "xianmao", "Value": 3, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "dudan", "Value": 3, "WX": [], "Level": 0, "Need": 120000},
		{"Name": "llzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "flzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "slzsp", "Value": 1, "WX": [], "Level": 0, "Need": 25000},
		{"Name": "hlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 10000},
		{"Name": "rls", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "bsz", "Value": 1, "WX": [], "Level": 0, "Need": 3000}
	],
	"Box_5":
	[
		{"Name": "bsd_5", "Value": 1, "WX": [], "Level": 0, "Need": 2200000},
		{"Name": "bsd_4", "Value": 1, "WX": [], "Level": 0, "Need": 800000},
		{"Name": "bsd_3", "Value": 1, "WX": [], "Level": 0, "Need": 320000},
		{"Name": "llzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "flzsp", "Value": 1, "WX": [], "Level": 0, "Need": 30000},
		{"Name": "slzsp", "Value": 1, "WX": [], "Level": 0, "Need": 25000},
		{"Name": "hlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tlzsp", "Value": 1, "WX": [], "Level": 0, "Need": 10000},
		{"Name": "llz", "Value": 1, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "flz", "Value": 1, "WX": [], "Level": 0, "Need": 80000},
		{"Name": "slz", "Value": 1, "WX": [], "Level": 0, "Need": 60000},
		{"Name": "hlz", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "tlz", "Value": 1, "WX": [], "Level": 0, "Need": 20000},
		{"Name": "tss", "Value": 1, "WX": [], "Level": 0, "Need": 70000},
		{"Name": "yhs", "Value": 1, "WX": [], "Level": 0, "Need": 70000},
		{"Name": "putongnmwsz", "Value": 1, "WX": [], "Level": 0, "Need": 50000},
		{"Name": "putongzlwsz", "Value": 1, "WX": [], "Level": 0, "Need": 50000}
	]
}
var MyNum: int
var NewList = {}
var MyFather
var IsOpen: bool
@onready var mystery_shop_item_box: TextureRect = $"."


func open():
	IsOpen = true
	ItemBox.disabled = false
	ItemBox.visible = true
	ItemNum.visible = true
	NeedValue.visible = true
	PurchaseButton.disabled = false
	PurchaseButton.visible = true
	mystery_shop_item_box.texture = load("res://Art/Shop/ShopItemBox.png")
	self.set_box()
	ItemNum.text = str(AE.AllEquipment_[NewList["Name"]][DataKeys.NAME]) + "×" + str(NewList["Value"])
	NeedValue.text = str(NewList["Need"]) + "灵魂"


func close():
	IsOpen = false
	mystery_shop_item_box.texture = load("res://Art/Shop/CloseItemBox.png")
	ItemBox.disabled = true
	ItemBox.visible = false
	ItemNum.text = ""
	ItemNum.visible = false
	NeedValue.text = ""
	NeedValue.visible = false
	PurchaseButton.disabled = true
	PurchaseButton.visible = false


func _ready() -> void:
	basic_set()


func get_list():
	return AllItemList["Box_" + str(MyNum)]


func basic_set():
	ItemBox.is_in_ldl_gz = true
	ItemBox.is_in_hhgz = true


func set_box():
	var CurrentList = AllItemList["Box_" + str(MyNum)]
	NewList = CurrentList[randi_range(0, CurrentList.size() - 1)]
	var Type = AE.AllEquipment_[NewList["Name"]][DataKeys.TYPE]
	match Type:
		"武器", "饰品", "防具", "时装", "头衔":
			ItemBox.qh_level = NewList["Level"]
			ItemBox.wx = []
		"法宝":
			ItemBox.wx = NewList["WX"]
		"道具", "消耗品":
			ItemBox.total_number = NewList["Value"]
	ItemBox.EQ_prop = AE.AllEquipment_[NewList["Name"]]
	ItemBox.get_item_name = NewList["Name"]
	ItemBox.set_meta("item_name", NewList["Name"])
	ItemBox.set_button_icon(load_(NewList["Name"]))


func _on_purchase_pressed() -> void:
	if PlayerData.player_data["购买次数"] <= 0:
		Global.add_message_show(Global.Windows_, "购买次数不足！！", 1.5, Vector2(470, 300))
		return
	var Need: int = NewList["Need"]
	if PlayerData.get_soul() < Need:
		Global.add_message_show(Global.Windows_, "灵魂不足！！", 1.5, Vector2(470, 300))
		return
	PlayerData.spend_soul(Need)
	PlayerData.player_data["购买次数"] -= 1
	var Type = AE.AllEquipment_[NewList["Name"]][DataKeys.TYPE]
	match Type:
		"武器", "饰品", "防具", "时装", "头衔":
			PlayerData.add_zb(NewList["Name"], NewList["Level"], {})
		"法宝":
			if NewList["WX"] == []:
				PlayerData.add_fb(NewList["Name"], 0, Global.get_wx(0), {})
			else:
				PlayerData.add_fb(NewList["Name"], 0, NewList["WX"], {})
		"道具":
			PlayerData.add_dj(NewList["Name"], NewList["Value"])
		"消耗品":
			PlayerData.add_xhp(NewList["Name"], NewList["Value"])
	Global.add_message_show(Global.Windows_, "购买成功", 1.5, Vector2(520, 340))
	open_and_close_box()
	MemoryClass.save_game(Global.cd_path)


func open_and_close_box():
	match int(MyNum):
		1:
			for i in MyFather.ChildList1:
				if i.IsOpen:
					i.open()
			for i in MyFather.ChildList2:
				if i.IsOpen:
					return
			if randi_range(0, 100) < 50:
				MyFather.item_2.open()
		2:
			self.close()
			MyFather.item_1.open()
			if randi_range(0, 100) < 50:
				MyFather.item_3.open()
		3:
			self.close()
			MyFather.item_1.open()
			if randi_range(0, 100) < 40:
				MyFather.item_4.open()
		4:
			self.close()
			MyFather.item_1.open()
			if randi_range(0, 100) < 10:
				MyFather.item_5.open()
		5:
			self.close()
			MyFather.item_1.open()


func load_(name_):
	var abc = load("res://Art/BackPack/AllItems/" + str(name_) + ".png")
	return abc


func _drive_item_hover(item_box) -> void:
	if item_box == null or not is_instance_valid(item_box):
		return
	if not item_box.visible:
		if _item_hover_inside:
			_item_hover_inside = false
			_hide_item_info()
		return
	var inside = item_box.get_global_rect().has_point(item_box.get_global_mouse_position())
	if inside and not _item_hover_inside:
		_item_hover_inside = true
		_show_item_info(item_box)
	elif inside and _item_hover_popup != null and is_instance_valid(_item_hover_popup):
		Global.apply_popup_screen_layout(_item_hover_popup, Global.screen_popup_position(), _hover_popup_size(item_box))
	elif not inside and _item_hover_inside:
		_item_hover_inside = false
		_hide_item_info()


func _hover_popup_size(item_box) -> Vector2:
	if item_box != null and is_instance_valid(item_box):
		var eq_prop = item_box.EQ_prop
		if eq_prop != null and eq_prop.size() > 0 and item_box.item_menu_kind != "item":
			return Vector2(260, 560)
	return Vector2(235, 240)


func _show_item_info(item_box) -> void:
	if item_box == null or not is_instance_valid(item_box):
		return
	if _item_hover_popup != null and is_instance_valid(_item_hover_popup):
		return
	var item_name = item_box.get_item_name
	if (item_name == "" or item_name == "empty") and item_box.has_meta("item_name"):
		item_name = str(item_box.get_meta("item_name"))
	if item_name == "" or item_name == "empty" or not AE.AllEquipment_.has(item_name):
		return
	var parent_node = Global.get_ui_popup_layer()
	var popup_pos = Global.screen_popup_position()
	var eq_prop = item_box.EQ_prop
	if eq_prop != null and eq_prop.size() > 0 and item_box.item_menu_kind != "item":
		_item_hover_popup = Global.add_equ_propeties_box(
			parent_node, popup_pos, item_name, item_box.qh_level, item_box.wx, eq_prop
		)
	else:
		_item_hover_popup = Global.add_dj_infor(parent_node, popup_pos, item_name)
	if _item_hover_popup != null:
		Global.register_hover_popup(_item_hover_popup)
		_item_hover_popup.top_level = true
		_item_hover_popup.z_index = 9999
		_item_hover_popup.visible = true


func _hide_item_info() -> void:
	Global.clear_hover_popup()
	_item_hover_popup = null
