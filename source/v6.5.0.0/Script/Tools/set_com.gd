extends Control

@onready var joy_right: Control = $joy_right
@onready var joy_left: Control = $joy_left
@onready var yg = $joy_left/joyBG/joy
@onready var control_: Control = $Control
@onready var size_: Slider = $Control/SizeBar
@onready var tmBar_: Slider = $Control/TMBar

var isSet: bool = false
var curNode: CanvasItem
var isClick: bool = false
var offser_: Vector2 = Vector2.ZERO
var touch_scale: float = 1.0
const keyPath: String = "user://KeyConfig.json"
const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")

const UserStr: PackedStringArray = ["wk", "ts", "bj", "ss", "bl", "bl"]
const KEY_BUTTON_COUNT: int = 11
const MOUNT_BUTTON_INDEX: int = 10
const JOY_CONFIG_INDEX: int = 11
const MAIN_SWORD_ARRAY_ICON_PATHS := {
	"zhuxianjian": ["res://Art/zhuxianjianzhen/ZhuXianSword/sprites/DefineSprite_61/1.png"],
	"xianxianjian": ["res://Art/zhuxianjianzhen/ZhuXianSword/sprites/DefineSprite_61/2.png"],
	"sijianheyi": ["res://Art/zhuxianjianzhen/ZhuXianSword/sprites/DefineSprite_61/3.png"],
	"luxianjian": ["res://Art/zhuxianjianzhen/ZhuXianSword/sprites/DefineSprite_61/4.png"],
	"juexianjian": ["res://Art/zhuxianjianzhen/ZhuXianSword/sprites/DefineSprite_61/5.png"],
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

var TextKeyTscn: PackedScene = preload("res://Scene/tools/user_key.tscn")
var keyList: Array = []
var playerData: Dictionary = {}
var keyObj: Dictionary = {}
var _dynamic_icons_initialized := false


func _ready() -> void:
	default_keys = keys.duplicate(true)
	playerData = PlayerData.player_data
	add_to_group("TouchControlSetCom")
	yg.isSet = isSet

	for i in range(KEY_BUTTON_COUNT):
		var node = TextKeyTscn.instantiate()
		node.isSet = isSet
		node.setKey = self
		keyList.append(node)
		joy_right.add_child(node)
		if isSet:
			node.pic_box.visible = false

	if not isSet:
		control_.queue_free()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		process_mode = Node.PROCESS_MODE_ALWAYS
		control_.visible = true
		curNode = keyList[0]

	set_jpng(7, "t")
	init()


func init() -> void:
	playerData = PlayerData.player_data
	var index: int = int(playerData.get("Myself", 1))
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
		var node = keyList[i]
		set_dic(obj, node)
		node.Text = obj["key"]
		node.TextKey.text = node.Text
		node.action = obj["ClickKey"]
		if node.has_method("_ensure_ws_effect"):
			node._ensure_ws_effect()
	_update_mount_button()
	set_dic(keys[JOY_CONFIG_INDEX], joy_left)
	apply_global_scale(_touch_icon_scale())


func _physics_process(_delta: float) -> void:
	if isSet and curNode != null:
		var nodeSize: Vector2 = curNode.get("size_") if curNode.get("size_") != null else Vector2(70, 70)
		var nodeSize_: float = min(nodeSize.x, nodeSize.y)
		var base_size: float = float(curNode.get("curSize")) if curNode.get("curSize") != null else max(nodeSize_, 1.0)
		var size_value: float = nodeSize_ / max(base_size, 1.0) * 100.0
		var alpha_value: float = curNode.modulate.a * 255.0
		if not is_equal_approx(size_.value, size_value):
			size_.value = size_value
		if not is_equal_approx(tmBar_.value, alpha_value):
			tmBar_.value = alpha_value

	var skill_data = playerData.get(DataKeys.SKILL_LEARNED, {})
	keyObj = skill_data.get("技能键位", {}) if skill_data is Dictionary else {}

	if isClick:
		joy_left.position = get_global_mouse_position() - offser_

	var mount_runtime := _current_mount_runtime()
	var use_mount_skills := (
		not isSet
		and mount_runtime != null
		and mount_runtime.has_method("is_riding_mount")
		and bool(mount_runtime.call("is_riding_mount"))
	)
	for i in range(5):
		var key_name: String = keys[i]["key"]
		var skill_name: String = str(keyObj.get(key_name, ""))
		var userKey = keyList[i]
		if use_mount_skills:
			var mount_skill: Dictionary = mount_runtime.call("get_mount_skill_for_slot", i)
			var mount_skill_id := str(mount_skill.get("id", ""))
			if (
				_dynamic_icons_initialized
				and int(userKey.mount_skill_slot) == i
				and userKey.SkillName == mount_skill_id
			):
				continue
			userKey.mount_skill_slot = i
			userKey.SkillName = mount_skill_id
			if mount_skill_id != "":
				userKey.TextKey.visible = false
				set_texture2_d(userKey, MOUNT_CATALOG.get_icon_path(mount_skill_id))
			else:
				userKey.TextKey.visible = true
				set_texture2_d(userKey, "res://Art/2_5_9_0/key/p.png")
			continue
		if int(userKey.mount_skill_slot) != -1:
			userKey.mount_skill_slot = -1
		if _dynamic_icons_initialized and userKey.SkillName == skill_name:
			continue
		userKey.SkillName = skill_name
		if skill_name != "":
			userKey.TextKey.visible = false
			set_texture2_d(
				userKey,
				_first_existing(
					[
						"res://Art/Skill/SkillIcon/" + skill_name + ".png",
						"res://Art/Skill/LittleSkillIcon/" + skill_name + ".png",
					]
				)
			)
		else:
			userKey.TextKey.visible = true
			set_texture2_d(userKey, "res://Art/2_5_9_0/key/p.png")

	var fbStr: String = str(playerData.get("实战法宝", ""))
	var userKey_ = keyList[5]
	if not _dynamic_icons_initialized or userKey_.SkillName != fbStr:
		userKey_.SkillName = fbStr
		if fbStr == "":
			userKey_.TextKey.visible = true
			set_texture2_d(userKey_, "res://Art/2_5_9_0/key/p.png")
		else:
			userKey_.TextKey.visible = false
			set_texture2_d(
				userKey_,
				_first_existing(
					[
						"res://Art/2_5_9_0/fbIcon/" + fbStr + ".png",
						"res://Art/MagicWeapon/Skill_Icon/" + fbStr + ".png",
						"res://Art/BackPack/AllItems/" + fbStr + ".png",
						"res://Art/ItemIcon/" + fbStr + ".png",
					]
				)
			)

	var wsKey = keyList[8]
	if not _dynamic_icons_initialized or wsKey.res_ == "":
		wsKey.SkillName = ""
		wsKey.TextKey.visible = false
		set_texture2_d(wsKey, "res://Art/RoleInfoIcon/416.png")

	var swordKey = keyList[9]
	var active_sword: String = _active_main_sword_array_id()
	var sword_visible := isSet or active_sword != ""
	if swordKey.visible != sword_visible:
		swordKey.visible = sword_visible
	if not _dynamic_icons_initialized or swordKey.SkillName != active_sword:
		swordKey.SkillName = active_sword
		if active_sword == "":
			swordKey.TextKey.visible = true
			if isSet:
				set_texture2_d(swordKey, "res://Art/2_5_9_0/key/p.png")
		else:
			swordKey.TextKey.visible = false
			set_texture2_d(swordKey, _main_sword_array_icon_path(active_sword))

	_update_mount_button()
	_dynamic_icons_initialized = true


func _update_mount_button() -> void:
	if MOUNT_BUTTON_INDEX < 0 or MOUNT_BUTTON_INDEX >= keyList.size():
		return
	var mount_key = keyList[MOUNT_BUTTON_INDEX]
	var mount_visible := PlayerData.is_mount_system_unlocked() and not PlayerData.get_active_mount().is_empty()
	if mount_visible:
		mount_key.Text = "Z"
		mount_key.TextKey.text = "Z"
		mount_key.TextKey.visible = true
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
	playerData = PlayerData.player_data
	var active := str(playerData.get(PlayerData.MAIN_SWORD_ARRAY_KEY, ""))
	if active != "" and PlayerData.has_method("can_main_sword_array_battle"):
		if not PlayerData.can_main_sword_array_battle(active):
			return ""
	return active


func _main_sword_array_icon_path(sword_id: String) -> String:
	return _first_existing(MAIN_SWORD_ARRAY_ICON_PATHS.get(sword_id, []))


func set_texture2_d(userKey, path: String) -> void:
	if path == "":
		path = "res://Art/2_5_9_0/key/p.png"
	var is_magic_weapon_icon := (
		path.find("/Art/2_5_9_0/fbIcon/") != -1
		or path.find("/Art/MagicWeapon/Skill_Icon/") != -1
		or path.find("/Art/BackPack/AllItems/") != -1
		or path.find("/Art/ItemIcon/") != -1
	)
	var is_main_sword_array_icon := path.find("/Art/zhuxianjianzhen/") != -1
	var is_mount_skill_icon := path.find("/Art/Mount/Skills/") != -1
	var is_skill_icon := (
		path.find("/Art/Skill/SkillIcon/") != -1
		or path.find("/Art/Skill/LittleSkillIcon/") != -1
		or is_mount_skill_icon
		or is_magic_weapon_icon
		or is_main_sword_array_icon
	)
	var res_key := ("frame:" + path + ":" + str(0.8)) if is_skill_icon else path
	if userKey.res_ == res_key:
		return
	userKey.res_ = res_key
	userKey.visible = false
	if userKey.has_method("set_framed_icon") and is_skill_icon:
		userKey.set_framed_icon(path, "res://Art/2_5_9_0/key/p.png", 0.8)
	elif userKey.has_method("set_button_texture"):
		userKey.set_button_texture(path)
	else:
		var res_: Texture2D = load(path)
		if res_ == null:
			res_ = load("res://Art/2_5_9_0/key/p.png")
		userKey.texture_normal = res_
		userKey.texture_pressed = res_
		userKey.pic_box.texture_progress = res_
	userKey.visible = true


func _on_button_pressed() -> void:
	for i in range(KEY_BUTTON_COUNT):
		get_dic(keys[i], keyList[i])
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
		var node = keyList[i]
		set_dic(obj, node)
		node.Text = obj["key"]
		node.TextKey.text = node.Text
		node.action = obj["ClickKey"]
		node.res_ = ""
		if node.has_method("_ensure_ws_effect"):
			node._ensure_ws_effect()
	set_dic(keys[JOY_CONFIG_INDEX], joy_left)
	curNode = keyList[0] if keyList.size() > 0 else null
	apply_global_scale(_touch_icon_scale())


func get_dic(obj: Dictionary, node: CanvasItem) -> void:
	var pos_: Dictionary = obj["position"]
	var size__: Dictionary = obj["size"]
	pos_["x"] = node.position.x
	pos_["y"] = node.position.y
	var nodeSize: Vector2 = node.get("size_") if node.get("size_") != null else Vector2(70, 70)
	size__["x"] = nodeSize.x
	size__["y"] = nodeSize.y
	obj["modulate"] = node.modulate.a
	obj["curSize"] = node.get("curSize") if node.get("curSize") != null else max(nodeSize.x, nodeSize.y)


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
	if index < 0 or index >= keyList.size():
		return
	var node = keyList[index]
	node.TextKey.visible = false
	set_texture2_d(node, _first_existing(["res://Art/2_5_9_0/png/" + str_ + ".png"]))


func _on_button_button_down() -> void:
	if isSet:
		curNode = joy_left
		offser_ = get_global_mouse_position() - joy_left.position
		isClick = true


func _on_button_button_up() -> void:
	isClick = false


func _on_tree_exited() -> void:
	_release_actions()
	if isSet:
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
	if curNode == null:
		return
	var base_size: float = float(curNode.get("curSize")) if curNode.get("curSize") != null else 70.0
	var curSizeValue: float = value / 100.0 * base_size
	if curNode.get("size_") != null:
		curNode.set("size_", Vector2(curSizeValue, curSizeValue))


func _on_tm_bar_value_changed(value: float) -> void:
	if curNode:
		curNode.modulate.a = value / 255.0


func _touch_icon_scale() -> float:
	var tc = get_node_or_null("/root/TouchControls")
	if tc != null:
		return float(tc.icon_scale)
	return 1.0


func _current_mount_runtime() -> Node:
	var player = RoleProp.SourcePlayer
	if player == null or not is_instance_valid(player):
		return null
	return player.get_node_or_null("MountRuntime")


func apply_global_scale(value: float) -> void:
	touch_scale = value
	for node in keyList:
		node.set("touch_scale", value)
	if joy_left != null:
		joy_left.set("touch_scale", value)


func set_joy_enabled(value: bool) -> void:
	if joy_left != null:
		joy_left.visible = value or isSet
	if yg != null:
		yg.isSet = isSet or not value
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
		role_info.isStop = false
