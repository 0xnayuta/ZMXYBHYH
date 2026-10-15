extends CanvasLayer

var controls_initialized: bool = false
var last_scene_path: String = ""
var last_ui_open: bool = false
var controls_enabled: bool = true
var icon_scale: float = 1.0
var settings_mode: bool = false

var is_android: bool = false
var _ui_check_elapsed: float = 0.0
var _control_scene: PackedScene = null

const CONTROL_SCENE: = "res://Scene/Tools/set_com.tscn"
const UI_CHECK_INTERVAL: = 0.12
const TOUCH_ACTIONS: = ["move_left", "move_right", "down", "Exit", "normalhit", "jump", "slz", "lys", "lyfb", "hmz", "hytj", "MagicWeapon", "无双", "阵法", "MDS", "backpack", "技能", "法宝"]

func _ready():
	process_mode = PROCESS_MODE_ALWAYS

func _process(delta: float) -> void :
	if settings_mode:
		return

	var cur = get_tree().current_scene
	var path: String = cur.scene_file_path if cur else ""
	var in_level: bool = path.begins_with("res://Scene/Level/") and is_android and controls_enabled
	if not in_level:
		last_scene_path = path
		last_ui_open = false
		_ui_check_elapsed = 0.0
		if controls_initialized:
			_clear_controls()
		return

	_ui_check_elapsed += delta
	if path == last_scene_path and _ui_check_elapsed < UI_CHECK_INTERVAL:
		return
	_ui_check_elapsed = 0.0

	var ui_open: = _has_ui_open()
	if path != last_scene_path or ui_open != last_ui_open:
		last_scene_path = path
		last_ui_open = ui_open
		if not ui_open and not controls_initialized:
			controls_initialized = true
			_init_controls(false)
		elif ui_open and controls_initialized:
			_clear_controls()

func _has_ui_open() -> bool:
	var ui_names = ["BackPack", "Main_Backpack", "zd_skill", "bd_skill", "SkillKeySet", "Set_Menu", "Learn_skill", "UseMagicWeapon", "MagicWeaponInfor", "MagicHelp", "SetCom"]
	return _find_ui_node(get_tree().root, ui_names)

func _find_ui_node(node: Node, names: Array) -> bool:
	for uname in names:
		if node.name == uname:
			return true
	for child in node.get_children():
		if child == self:
			continue
		if _find_ui_node(child, names):
			return true
	return false

func _init_controls(is_set_mode: bool):
	var scene: = _get_control_scene()
	if scene == null:
		push_warning("TouchControls: mobile control scene not found")
		return
	var cn = scene.instantiate()
	_set_if_has_property(cn, "isSet", is_set_mode)
	add_child(cn)

func _set_if_has_property(obj: Object, prop_name: String, value) -> void :
	for p in obj.get_property_list():
		if str(p.get("name", "")) == prop_name:
			obj.set(prop_name, value)
			return

func _clear_controls():
	_release_touch_actions()
	for child in get_children():
		child.queue_free()
	controls_initialized = false

func _release_touch_actions():
	for action in TOUCH_ACTIONS:
		if InputMap.has_action(action):
			Input.action_release(action)

func _get_control_scene() -> PackedScene:
	if _control_scene != null:
		return _control_scene
	if ResourceLoader.exists(CONTROL_SCENE):
		_control_scene = load(CONTROL_SCENE)
	return _control_scene

func set_controls_enabled(value: bool) -> void :
	controls_enabled = value
	if not controls_enabled:
		_clear_controls()

func toggle_controls_enabled() -> bool:
	set_controls_enabled( not controls_enabled)
	return controls_enabled

func set_icon_scale(value: float) -> void :
	icon_scale = value
	for child in get_children():
		if child.has_method("apply_global_scale"):
			child.apply_global_scale(icon_scale)

func open_settings() -> void :
	_clear_controls()
	settings_mode = true
	controls_initialized = false
	get_tree().paused = true
	var scene: = _get_control_scene()
	if scene == null:
		settings_mode = false
		get_tree().paused = false
		push_warning("TouchControls: settings scene not found")
		return
	var cn = scene.instantiate()
	_set_if_has_property(cn, "isSet", true)
	add_child(cn)
	cn.tree_exited.connect( func():
		settings_mode = false
		controls_initialized = false
		_release_touch_actions()
		get_tree().paused = false
	)
