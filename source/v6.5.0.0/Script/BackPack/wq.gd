extends Button
var add_equ_box
var get_item_name
var qh_level: int
var pp
var wx = []
var EQ_prop = {}
var _slot_background_ready := false
var _slot_background_item_visible := false
var _avatar_frame_signature := ""
var _shengu_signature := ""


func _ready() -> void:
	_sync_avatar_frame_equipment(true)
	_sync_shengu_equipment(true)
	_ensure_slot_background()


func _ensure_slot_background() -> void:
	if _slot_background_ready:
		return
	_sync_slot_background_style(true)
	_slot_background_ready = true


func _sync_slot_background_style(force := false) -> void:
	var item_visible := _has_item_icon()
	if not force and _slot_background_item_visible == item_visible and _slot_background_ready:
		return
	_slot_background_item_visible = item_visible
	var slot_name := str(self.name)
	var bg_path := (
		"res://Art/BackPack/AllItems/empty.png" if item_visible else "res://Art/BackPack/AllItems/" + slot_name + ".png"
	)
	var bg_texture = load(bg_path) if ResourceLoader.exists(bg_path) else load("res://Art/BackPack/AllItems/empty.png")
	for style_name in ["normal", "pressed", "hover", "disabled", "focus"]:
		var style := StyleBoxTexture.new()
		style.texture = bg_texture
		add_theme_stylebox_override(style_name, style)


func _has_item_icon() -> bool:
	if icon == null or icon.resource_path == "":
		return false
	var path := icon.resource_path
	if not path.contains("/AllItems/"):
		return false
	var icon_name := path.split("/AllItems/")[1].split(".")[0]
	return not ["empty", "wq", "fj", "sp", "fb", "sz", "cb", "tx", "txk", "shengu"].has(icon_name)


func _sync_avatar_frame_equipment(force := false) -> void:
	if str(name) != "txk":
		return
	var equipped: Array = PlayerData.ensure_avatar_frame_slot()
	var signature := "empty"
	if not equipped.is_empty() and equipped[0] is Dictionary:
		var item: Dictionary = equipped[0]
		signature = (
			"%s:%d:%s"
			% [
				str(item.get(DataKeys.NAME, "")),
				int(item.get(DataKeys.ENHANCE_LEVEL, 0)),
				str(item.get("Data", {})),
			]
		)
	if not force and signature == _avatar_frame_signature:
		return
	_avatar_frame_signature = signature
	if equipped.is_empty() or not (equipped[0] is Dictionary):
		get_item_name = ""
		qh_level = 0
		EQ_prop = {}
		set_button_icon(load("res://Art/BackPack/AllItems/empty.png"))
		return
	var item: Dictionary = equipped[0]
	get_item_name = str(item.get(DataKeys.NAME, ""))
	qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	EQ_prop = item.get("Data", {})
	var item_icon_path: String = "res://Art/BackPack/AllItems/" + str(get_item_name) + ".png"
	var item_icon = (
		load(item_icon_path) if ResourceLoader.exists(item_icon_path) else load("res://Art/BackPack/AllItems/empty.png")
	)
	set_button_icon(item_icon)


func _sync_shengu_equipment(force := false) -> void:
	if str(name) != "shengu":
		return
	var equipped: Array = PlayerData.ensure_shengu_slot()
	var signature := "empty"
	if not equipped.is_empty() and equipped[0] is Dictionary:
		signature = str(equipped[0])
	if not force and signature == _shengu_signature:
		return
	_shengu_signature = signature
	if equipped.is_empty() or not (equipped[0] is Dictionary):
		get_item_name = ""
		qh_level = 0
		EQ_prop = {}
		set_button_icon(load("res://Art/BackPack/AllItems/empty.png"))
		return
	var item: Dictionary = equipped[0]
	get_item_name = str(item.get(DataKeys.NAME, ""))
	qh_level = int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	EQ_prop = item.get("Data", {})
	var item_icon_path: String = "res://Art/BackPack/AllItems/" + str(get_item_name) + ".png"
	set_button_icon(
		load(item_icon_path) if ResourceLoader.exists(item_icon_path) else load("res://Art/BackPack/AllItems/empty.png")
	)


func _mouse_position_for_popup(parent_node: Node, offset := Vector2(25, 20)) -> Vector2:
	var mouse_pos := get_tree().get_root().get_mouse_position() + offset
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * mouse_pos
	return mouse_pos


func _physics_process(_delta: float) -> void:
	_sync_avatar_frame_equipment()
	_sync_shengu_equipment()
	_sync_slot_background_style()
	if add_equ_box != null:
		var popup_parent = add_equ_box.get_parent()
		if popup_parent != null:
			pp = _mouse_position_for_popup(popup_parent)
			add_equ_box.position = pp


func _on_pressed() -> void:
	if PlayerData.check_can_use_page("装备列表") == 0:
		Global.add_message_show(Global.get_parent_(self, 5), "背包已满，无法卸下！！", 1.5, Vector2(80, 0))
		return
	match str(self.name):
		"wq":
			if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
				var name_ = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data[DataKeys.WEAPON][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/wq.png"))
			PlayerData.player_data[DataKeys.WEAPON].clear()
		"fj":
			if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
				var name_ = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data[DataKeys.ARMOR][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/fj.png"))
			PlayerData.player_data[DataKeys.ARMOR].clear()
		"sp":
			if PlayerData.player_data["饰品"].size() != 0:
				var name_ = PlayerData.player_data["饰品"][0][DataKeys.NAME]
				var ql = PlayerData.player_data["饰品"][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data["饰品"][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/sp.png"))
			PlayerData.player_data["饰品"].clear()
		"shengu":
			var equipped: Array = PlayerData.ensure_shengu_slot()
			if not equipped.is_empty() and equipped[0] is Dictionary:
				var item: Dictionary = equipped[0]
				PlayerData.add_zb(
					str(item.get(DataKeys.NAME, "")), int(item.get(DataKeys.ENHANCE_LEVEL, 0)), item.get("Data", {})
				)
			equipped.clear()
			_shengu_signature = ""
			_sync_shengu_equipment(true)
		"tx":
			if PlayerData.player_data[DataKeys.TITLE].size() != 0:
				var name_ = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data[DataKeys.TITLE][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/AllItems/tx.png"))
			PlayerData.player_data[DataKeys.TITLE].clear()
		"txk":
			var equipped: Array = PlayerData.ensure_avatar_frame_slot()
			if not equipped.is_empty() and equipped[0] is Dictionary:
				var item: Dictionary = equipped[0]
				PlayerData.add_zb(
					str(item.get(DataKeys.NAME, "")), int(item.get(DataKeys.ENHANCE_LEVEL, 0)), item.get("Data", {})
				)
			equipped.clear()
			_avatar_frame_signature = ""
			_sync_avatar_frame_equipment(true)
		"sz":
			if PlayerData.player_data[DataKeys.FASHION].size() != 0:
				var name_ = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data[DataKeys.FASHION][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/sz.png"))
			PlayerData.player_data[DataKeys.FASHION].clear()
		"cb":
			if PlayerData.player_data[DataKeys.WINGS].size() != 0:
				var name_ = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
				var ql = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.ENHANCE_LEVEL]
				EQ_prop = PlayerData.player_data[DataKeys.WINGS][0]["Data"]
				PlayerData.add_zb(name_, ql, EQ_prop)
			else:
				set_button_icon(load("res://Art/BackPack/cb.png"))
			PlayerData.player_data[DataKeys.WINGS].clear()
		"fb":
			if Global.FB_CD <= 0:
				if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
					var name_ = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
					var ql = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
					var wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
					EQ_prop = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
					PlayerData.add_fb(name_, ql, wx, EQ_prop)
				else:
					set_button_icon(load("res://Art/BackPack/fb.png"))
				PlayerData.player_data[DataKeys.MAGIC_WEAPON].clear()
			else:
				Global.add_message_show(Global.get_parent_(self, 5), "当前法宝正在使用，无法更换！！", 1.5, Vector2(80, 0))
	qh_level = 0
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.SourcePlayer):
		RoleProp.SourcePlayer.onEqchange()
	MemoryClass.save_game(Global.cd_path)


func _on_mouse_entered() -> void:
	if icon == null or icon.resource_path == "" or not icon.resource_path.contains("/AllItems/"):
		return
	var path_name = icon.resource_path.split("/AllItems/")[1].split(".")[0]
	if (
		path_name == "sp"
		or path_name == "wq"
		or path_name == "fj"
		or path_name == "fb"
		or path_name == "sz"
		or path_name == "cb"
		or path_name == "tx"
		or path_name == "txk"
		or path_name == "shengu"
	):
		return
	if (
		str(self.name) == "cb"
		or str(self.name) == "sz"
		or str(self.name) == "tx"
		or str(self.name) == "txk"
		or str(self.name) == "shengu"
	):
		if Global.get_parent_(self, 3).get_icon_name(self) != "empty" and add_equ_box == null:
			var popup_parent = Global.get_parent_(self, 3)
			pp = _mouse_position_for_popup(popup_parent)
			add_equ_box = Global.add_equ_propeties_box(popup_parent, pp, get_item_name, qh_level, wx, EQ_prop)
	else:
		if Global.get_parent_(self, 5).get_icon_name(self) != "empty" and add_equ_box == null:
			var popup_parent = Global.get_parent_(self, 5)
			pp = _mouse_position_for_popup(popup_parent)
			add_equ_box = Global.add_equ_propeties_box(popup_parent, pp, get_item_name, qh_level, wx, EQ_prop)


func _on_mouse_exited() -> void:
	if add_equ_box != null:
		add_equ_box.queue_free()
