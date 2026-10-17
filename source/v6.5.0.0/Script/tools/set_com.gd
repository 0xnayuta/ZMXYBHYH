extends Control

@onready var joy_right: Control = $joy_right
@onready var joy_left: Control = $joy_left
@onready var yg = $joy_left/joyBG/joy
@onready var control_: Control = $Control
@onready var size_: Slider = $Control/SizeBar
@onready var tm_bar: Slider = $Control/TMBar

var is_set: bool = false
var cur_node: CanvasItem
var is_click: bool = false
var offser_: Vector2 = Vector2.ZERO
var touch_scale: float = 1.0
const keyPath: String = "user://KeyConfig.json"
const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")

const UserStr: PackedStringArray = ["wk", "ts", "bj", "ss", "bl", "bl"]
const KEY_BUTTON_COUNT: int = 11
const MOUNT_BUTTON_INDEX: int = 10
const JOY_CONFIG_INDEX: int = 11
const MAIN_SWORD_ARRAY_ICON_PATHS := {
	"zhuxianjian": ["res://Art/zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61/1.png"],
	"xianxianjian": ["res://Art/zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61/2.png"],
	"sijianheyi": ["res://Art/zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61/3.png"],
	"luxianjian": ["res://Art/zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61/4.png"],
	"juexianjian": ["res://Art/zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61/5.png"],
}

var default_keys: Array = []
var keys: Array = [
	{
		"key": "Y",
		"ClickKey": "slz",
		"position": {"x": -296, "y": -47},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "U",
		"ClickKey": "lys",
		"position": {"x": -222, "y": -47},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "I",
		"ClickKey": "lyfb",
		"position": {"x": -224, "y": -131},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "O",
		"ClickKey": "hmz",
		"position": {"x": -164, "y": -188},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "L",
		"ClickKey": "hytj",
		"position": {"x": -82, "y": -181},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "H",
		"ClickKey": "MagicWeapon",
		"position": {"x": -45, "y": -254},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 50.0
	},
	{
		"key": "J",
		"ClickKey": "normalhit",
		"position": {"x": -144, "y": -89},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 100.0
	},
	{
		"key": "K",
		"ClickKey": "jump",
		"position": {"x": -52, "y": -106},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 100.0
	},
	{
		"key": "无双",
		"ClickKey": "无双",
		"position": {"x": -380, "y": -47},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 70.0
	},
	{
		"key": "P",
		"ClickKey": "MDS",
		"position": {"x": -130, "y": -254},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 70.0
	},
	{
		"key": "Z",
		"ClickKey": "MountToggle",
		"position": {"x": -215, "y": -254},
		"size": {"x": 70, "y": 70},
		"modulate": 1.0,
		"curSize": 70.0
	},
	{
		"key": "",
		"ClickKey": "",
		"position": {"x": 30, "y": 400},
		"size": {"x": 200, "y": 200},
		"modulate": 1.0,
		"curSize": 200.0
	},
]

var text_key_tscn: PackedScene = preload("res://Scene/tools/user_key.tscn")
var key_list: Array = []
var player_data: Dictionary = {}
var key_obj: Dictionary = {}
var _dynamic_icons_initialized := false


func _ready() -> void:
	default_keys = keys.duplicate(true)
	player_data = PlayerData.player_data
	add_to_group("TouchControlSetCom")
	yg.is_set = is_set

	for i in range(KEY_BUTTON_COUNT):
		var node = text_key_tscn.instantiate()
		node.is_set = is_set
		node.set_key = self
		key_list.append(node)
		joy_right.add_child(node)
		if is_set:
			node.pic_box.visible = false

	if not is_set:
		control_.queue_free()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		control_.visible = true
		cur_node = key_list[0]

	set_jpng(7, "t")
	init()


func init() -> void:
	player_data = PlayerData.player_data
	var index: int = int(player_data.get("Myself", 1))
	if index < 1 or index > UserStr.size():
		index = 1
	set_jpng(6, UserStr[index - 1])

	if FileAccess.file_exists(keyPath):
		var data: String = FileAccess.get_file_as_string(keyPath)
		var datas = JSON.parse_string(data)
		if datas is Array:
			var load_datas: Array = datas
			if load_datas.size() == 10:
				load_datas = load_datas.duplicate(true)
				load_datas.insert(9, keys[9].duplicate(true))
			if load_datas.size() == 11:
				load_datas = load_datas.duplicate(true)
				load_datas.insert(MOUNT_BUTTON_INDEX, keys[MOUNT_BUTTON_INDEX].duplicate(true))
			for i in range(min(load_datas.size(), keys.size())):
				if load_datas[i] is Dictionary:
					for j in load_datas[i].keys():
						keys[i][j] = load_datas[i][j]

	for i in range(KEY_BUTTON_COUNT):
		var obj: Dictionary = keys[i]
		var node = key_list[i]
		set_dic(obj, node)
		node.text_str = obj["key"]
		node.text_key.text = node.text_str
		node.action = obj["ClickKey"]
		if node.has_method("_ensure_ws_effect"):
			node._ensure_ws_effect()
	_update_mount_button()
	set_dic(keys[JOY_CONFIG_INDEX], joy_left)
	apply_global_scale(_touch_icon_scale())


func _physics_process(_delta: float) -> void:
	if is_set and cur_node != null:
		var node_size: Vector2 = cur_node.get("size_") if cur_node.get("size_") != null else Vector2(70, 70)
		var size_min: float = min(node_size.x, node_size.y)
		var base_size: float = float(cur_node.get("curSize")) if cur_node.get("curSize") != null else max(size_min, 1.0)
		var size_value: float = size_min / max(base_size, 1.0) * 100.0
		var alpha_value: float = cur_node.modulate.a * 255.0
		if not is_equal_approx(size_.value, size_value):
			size_.value = size_value
		if not is_equal_approx(tm_bar.value, alpha_value):
			tm_bar.value = alpha_value

	var skill_data = player_data.get(DataKeys.SKILL_LEARNED, {})
	key_obj = skill_data.get("技能键位", {}) if skill_data is Dictionary else {}

	if is_click:
		joy_left.position = get_global_mouse_position() - offser_

	var mount_runtime := _current_mount_runtime()
	var use_mount_skills := (
		not is_set
		and mount_runtime != null
		and mount_runtime.has_method("is_riding_mount")
		and bool(mount_runtime.call("is_riding_mount"))
	)
	for i in range(5):
		var key_name: String = keys[i]["key"]
		var skill_name: String = str(key_obj.get(key_name, ""))
		var user_key = key_list[i]
		if use_mount_skills:
			var mount_skill: Dictionary = mount_runtime.call("get_mount_skill_for_slot", i)
			var mount_skill_id := str(mount_skill.get("id", ""))
			if (
				_dynamic_icons_initialized
				and int(user_key.mount_skill_slot) == i
				and user_key.skill_name == mount_skill_id
			):
				continue
			user_key.mount_skill_slot = i
			user_key.skill_name = mount_skill_id
			if mount_skill_id != "":
				user_key.text_key.visible = false
				set_texture2_d(user_key, MOUNT_CATALOG.get_icon_path(mount_skill_id))
			else:
				user_key.text_key.visible = true
				set_texture2_d(user_key, "res://Art/2_5_9_0/key/p.png")
			continue
		if int(user_key.mount_skill_slot) != -1:
			user_key.mount_skill_slot = -1
		if _dynamic_icons_initialized and user_key.skill_name == skill_name:
			continue
		user_key.skill_name = skill_name
		if skill_name != "":
			user_key.text_key.visible = false
			set_texture2_d(
				user_key,
				_first_existing(
					[
						"res://Art/skill/skill_icon/" + skill_name + ".png",
						"res://Art/skill/little_skill_icon/" + skill_name + ".png",
					]
				)
			)
		else:
			user_key.text_key.visible = true
			set_texture2_d(user_key, "res://Art/2_5_9_0/key/p.png")

	var fb_str: String = str(player_data.get("实战法宝", ""))
	var user_key = key_list[5]
	if not _dynamic_icons_initialized or user_key.skill_name != fb_str:
		user_key.skill_name = fb_str
		if fb_str == "":
			user_key.text_key.visible = true
			set_texture2_d(user_key, "res://Art/2_5_9_0/key/p.png")
		else:
			user_key.text_key.visible = false
			set_texture2_d(
				user_key,
				_first_existing(
					[
						"res://Art/2_5_9_0/fbIcon/" + fb_str + ".png",
						"res://Art/magic_weapon/Skill_Icon/" + fb_str + ".png",
						"res://Art/backpack/AllItems/" + fb_str + ".png",
						"res://Art/item_icon/" + fb_str + ".png",
					]
				)
			)

	var ws_key = key_list[8]
	if not _dynamic_icons_initialized or ws_key.res_ == "":
		ws_key.skill_name = ""
		ws_key.text_key.visible = false
		set_texture2_d(ws_key, "res://Art/role_info_icon/416.png")

	var sword_key = key_list[9]
	var active_sword: String = _active_main_sword_array_id()
	var sword_visible := is_set or active_sword != ""
	if sword_key.visible != sword_visible:
		sword_key.visible = sword_visible
	if not _dynamic_icons_initialized or sword_key.skill_name != active_sword:
		sword_key.skill_name = active_sword
		if active_sword == "":
			sword_key.text_key.visible = true
			if is_set:
				set_texture2_d(sword_key, "res://Art/2_5_9_0/key/p.png")
		else:
			sword_key.text_key.visible = false
			set_texture2_d(sword_key, _main_sword_array_icon_path(active_sword))

	_update_mount_button()
	_dynamic_icons_initialized = true


func _update_mount_button() -> void:
	if MOUNT_BUTTON_INDEX < 0 or MOUNT_BUTTON_INDEX >= key_list.size():
		return
	var mount_key = key_list[MOUNT_BUTTON_INDEX]
	var mount_visible := PlayerData.is_mount_system_unlocked() and not PlayerData.get_active_mount().is_empty()
	if mount_visible:
		mount_key.text_str = "Z"
		mount_key.text_key.text = "Z"
		mount_key.text_key.visible = true
		if mount_key.res_ == "":
			set_texture2_d(mount_key, "res://Art/2_5_9_0/key/p.png")
	mount_key.visible = mount_visible


func _first_existing(paths: Array) -> String:
	for path in paths:
		if ResourceLoader.exists(path):
			return path
	return "res://Art/2_5_9_0/key/p.png"


func _active_main_sword_array_id() -> String:
	if PlayerData == null:
		return ""
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	player_data = PlayerData.player_data
	var active := str(player_data.get(PlayerData.MAIN_SWORD_ARRAY_KEY, ""))
	if active != "" and PlayerData.has_method("can_main_sword_array_battle"):
		if not PlayerData.can_main_sword_array_battle(active):
			return ""
	return active


func _main_sword_array_icon_path(sword_id: String) -> String:
	return _first_existing(MAIN_SWORD_ARRAY_ICON_PATHS.get(sword_id, []))


func set_texture2_d(user_key, path: String) -> void:
	if path == "":
		path = "res://Art/2_5_9_0/key/p.png"
	var is_magic_weapon_icon := (
		path.find("/Art/2_5_9_0/fbIcon/") != -1
		or path.find("/Art/magic_weapon/Skill_Icon/") != -1
		or path.find("/Art/backpack/AllItems/") != -1
		or path.find("/Art/item_icon/") != -1
	)
	var is_main_sword_array_icon := path.find("/Art/zhuxianjianzhen/") != -1
	var is_mount_skill_icon := path.find("/Art/mount/skills/") != -1
	var is_skill_icon := (
		path.find("/Art/skill/skill_icon/") != -1
		or path.find("/Art/skill/little_skill_icon/") != -1
		or is_mount_skill_icon
		or is_magic_weapon_icon
		or is_main_sword_array_icon
	)
	var res_key := ("frame:" + path + ":" + str(0.8)) if is_skill_icon else path
	if user_key.res_ == res_key:
		return
	user_key.res_ = res_key
	user_key.visible = false
	if user_key.has_method("set_framed_icon") and is_skill_icon:
		user_key.set_framed_icon(path, "res://Art/2_5_9_0/key/p.png", 0.8)
	elif user_key.has_method("set_button_texture"):
		user_key.set_button_texture(path)
	else:
		var res_: Texture2D = load(path)
		if res_ == null:
			res_ = load("res://Art/2_5_9_0/key/p.png")
		user_key.texture_normal = res_
		user_key.texture_pressed = res_
		user_key.pic_box.texture_progress = res_
	user_key.visible = true


func _on_button_pressed() -> void:
	for i in range(KEY_BUTTON_COUNT):
		get_dic(keys[i], key_list[i])
	get_dic(keys[JOY_CONFIG_INDEX], joy_left)
	_save_keys_config()
	get_tree().call_group("TouchControlSetCom", "init")
	if Global.has_method("add_message_show"):
		Global.add_message_show(self, "保存成功！", 1.5, Vector2(470, 300))


func _save_keys_config() -> void:
	var file := FileAccess.open(keyPath, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(keys))
		file.flush()
		file.close()


func _on_reset_layout_pressed() -> void:
	keys = default_keys.duplicate(true)
	_apply_keys_to_nodes()
	_save_keys_config()
	if Global.has_method("add_message_show"):
		Global.add_message_show(self, "布局已重置！", 1.5, Vector2(470, 300))


func _apply_keys_to_nodes() -> void:
	for i in range(KEY_BUTTON_COUNT):
		var obj: Dictionary = keys[i]
		var node = key_list[i]
		set_dic(obj, node)
		node.text_str = obj["key"]
		node.text_key.text = node.text_str
		node.action = obj["ClickKey"]
		node.res_ = ""
		if node.has_method("_ensure_ws_effect"):
			node._ensure_ws_effect()
	set_dic(keys[JOY_CONFIG_INDEX], joy_left)
	cur_node = key_list[0] if key_list.size() > 0 else null
	apply_global_scale(_touch_icon_scale())


func get_dic(obj: Dictionary, node: CanvasItem) -> void:
	var pos_: Dictionary = obj["position"]
	var size__: Dictionary = obj["size"]
	pos_["x"] = node.position.x
	pos_["y"] = node.position.y
	var node_size: Vector2 = node.get("size_") if node.get("size_") != null else Vector2(70, 70)
	size__["x"] = node_size.x
	size__["y"] = node_size.y
	obj["modulate"] = node.modulate.a
	obj["curSize"] = node.get("curSize") if node.get("curSize") != null else max(node_size.x, node_size.y)


func set_dic(obj: Dictionary, node: CanvasItem) -> void:
	var size__: Dictionary = obj["size"]
	if node.get("size_") != null:
		node.set("size_", Vector2(float(size__.get("x", 70)), float(size__.get("y", 70))))
	var pos: Dictionary = obj["position"]
	node.position = Vector2(float(pos.get("x", 0)), float(pos.get("y", 0)))
	node.modulate.a = float(obj.get("modulate", 1.0))
	if node.get("curSize") != null:
		node.set("curSize", float(obj.get("curSize", 50)))


func _on_button_2_pressed() -> void:
	_clear_role_stop()
	queue_free()


func set_jpng(index: int, str_: String) -> void:
	if index < 0 or index >= key_list.size():
		return
	var node = key_list[index]
	node.text_key.visible = false
	set_texture2_d(node, _first_existing(["res://Art/2_5_9_0/png/" + str_ + ".png"]))


func _on_button_button_down() -> void:
	if is_set:
		cur_node = joy_left
		offser_ = get_global_mouse_position() - joy_left.position
		is_click = true


func _on_button_button_up() -> void:
	is_click = false


func _on_tree_exited() -> void:
	_release_actions()
	if is_set:
		_clear_role_stop()


func _release_actions() -> void:
	for action_name in [
		"move_left",
		"move_right",
		"down",
		"Exit",
		"normalhit",
		"jump",
		"slz",
		"lys",
		"lyfb",
		"hmz",
		"hytj",
		"MagicWeapon",
		"无双",
		"MDS"
	]:
		if InputMap.has_action(action_name):
			Input.action_release(action_name)


func _on_size_bar_value_changed(value: float) -> void:
	if cur_node == null:
		return
	var base_size: float = float(cur_node.get("curSize")) if cur_node.get("curSize") != null else 70.0
	var cur_size_value: float = value / 100.0 * base_size
	if cur_node.get("size_") != null:
		cur_node.set("size_", Vector2(cur_size_value, cur_size_value))


func _on_tm_bar_value_changed(value: float) -> void:
	if cur_node:
		cur_node.modulate.a = value / 255.0


func _touch_icon_scale() -> float:
	var tc = get_node_or_null("/root/TouchControls")
	if tc != null:
		return float(tc.icon_scale)
	return 1.0


func _current_mount_runtime() -> Node:
	var player = RoleProp.source_player
	if player == null or not is_instance_valid(player):
		return null
	return player.get_node_or_null("MountRuntime")


func apply_global_scale(value: float) -> void:
	touch_scale = value
	for node in key_list:
		node.set("touch_scale", value)
	if joy_left != null:
		joy_left.set("touch_scale", value)


func set_joy_enabled(value: bool) -> void:
	if joy_left != null:
		joy_left.visible = value or is_set
	if yg != null:
		yg.is_set = is_set or not value
		if not value and yg.has_method("_release_dirs"):
			yg._release_dirs()
	if not value:
		_release_actions()


func _clear_role_stop() -> void:
	if not is_inside_tree():
		return
	var tree := get_tree()
	if tree == null:
		return
	var role_info = tree.get_first_node_in_group("RoleInformation")
	if role_info != null:
		role_info.is_stop = false
