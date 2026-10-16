extends Node2D
const MAIN_MENU_DESIGN_SIZE := Vector2(940.0, 590.0)
var abx: TextureButton
@onready var ar_infer: Node2D = $ar_infer
@onready var BGset: Node2D = $BGset

@onready var begin_game: TextureButton = $Begin_game

@onready var Music_set = $Music_set

@onready var music: TextureButton = $music

@onready var tiaoguo: TextureButton = $tiaoguo
@onready var tiaoguo_label: Label = $tiaoguo/tiaoguo_label

@onready var BackGround = $background
@onready var name_: Label = $name

@onready var name_2: Label = $name/name2
@onready var http_request: HTTPRequest = $HTTPRequest
var Times: int = 0
var my_music
var is_playing = false
var cd_jm
var message_box
var music_jm
var GameSet_: GameSet
var _last_plot_skip: Variant = null
var _last_main_menu_bg := -1
var _active_main_menu_background_path := ""


func _fit_main_menu_to_viewport() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / MAIN_MENU_DESIGN_SIZE.x, viewport_size.y / MAIN_MENU_DESIGN_SIZE.y)
	var menu_size = MAIN_MENU_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - menu_size) * 0.5


func _menu_content_parent() -> Node:
	return self


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_fit_main_menu_to_viewport()


func _ready() -> void:
	if not get_viewport().size_changed.is_connected(_fit_main_menu_to_viewport):
		get_viewport().size_changed.connect(_fit_main_menu_to_viewport)
	_fit_main_menu_to_viewport()
	_apply_main_menu_background(int(MainSet.set_data.get("MainMenuBG", 1)))
	if Global == null:
		print("错误：Global 未加载")
		return
	if MainSet.set_data.has("FileValue"):
		if float(MainSet.set_data["FileValue"]) < float(Global.FileNum):
			MainSet.set_data["FileValue"] = Global.FileNum
	Global.cd_path = ""
	Global.CollectNum = 0
	Global.LLBTLevel = 1
	Global.LLBTBOSSMS = false
	Global.LLBTCGMS = false
	Global.LLBTWXMS = false
	Global.Windows_ = get_parent()
	Global.FB_CD = 0
	Global.is_EyeFix = false
	Global.is_DeadLink = false
	MemoryClass.remove_play_data()
	RoleProp.ws_value = 0
	MemoryClass.main_dq()
	if MainMusic.MyMainMusic == null:
		MainMusic.ADDMusic()
	if MainSet.set_data["FristGame"]:
		Global.addGameNeedKnow(_menu_content_parent(), Vector2(0, 0))
		pass


func _exit_tree() -> void:
	BackGround.texture = null
	Global.release_cached_texture(_active_main_menu_background_path)
	_active_main_menu_background_path = ""


func _apply_main_menu_background(index: int) -> void:
	var clamped_index := clampi(index, 1, 6)
	var next_background_path := "res://Art/MainGame/背景%d_runtime.jpg" % clamped_index
	if _active_main_menu_background_path != "" and _active_main_menu_background_path != next_background_path:
		BackGround.texture = null
		Global.release_cached_texture(_active_main_menu_background_path)
	_active_main_menu_background_path = next_background_path
	_last_main_menu_bg = clamped_index
	match clamped_index:
		1:
			name_2.text = "《八荒湮隳篇·力战七大魔王》"
		2:
			name_2.text = "《八荒湮隳篇·勇斗十殿阎罗》"
		3:
			name_2.text = "《八荒湮隳篇·智取十万天兵》"
		4, 5, 6:
			name_2.text = ""
	BackGround.texture = (
		ResourceLoader.load(next_background_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
	)


func _physics_process(_delta: float) -> void:
	var plot_skip := bool(MainSet.set_data["剧情跳过"])
	if plot_skip != _last_plot_skip:
		_last_plot_skip = plot_skip
		tiaoguo_label.text = "显示剧情" if plot_skip else "跳过剧情"
	var main_menu_bg := int(MainSet.set_data["MainMenuBG"])
	if main_menu_bg != _last_main_menu_bg and main_menu_bg >= 1 and main_menu_bg <= 6:
		_apply_main_menu_background(main_menu_bg)
	RoleProp.ws_value = 0
	var music_menu_open := Music_set.get_child_count() != 0
	if music.disabled != music_menu_open:
		music.disabled = music_menu_open
	if music_menu_open:
		if music_jm != null:
			if music_jm.is_change:
				MainMusic.ADDMusic()
				music_jm.is_change = false
	if GameSet_ != null:
		if GameSet_.MusicIsChange:
			MainMusic.ADDMusic()
			GameSet_.MusicIsChange = false


func _on_begin_game_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")

	if ar_infer.get_child_count() == 0:
		cd_jm = Global.add_cd_jm(ar_infer, Vector2(0, 0))


func _on_music_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	music_jm = Global.add_music_set(Music_set, Vector2(0, 0))


func _on_gmae_help_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.add_gm_infor(_menu_content_parent(), Vector2(0, 0))


func _on_tiaoguo_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	if MainSet.set_data["剧情跳过"]:
		MainSet.set_data["剧情跳过"] = false
		Global.AddMessageShow(get_parent(), "将不会跳过结束剧情！！", 1.5, Vector2(470, 340))
	else:
		MainSet.set_data["剧情跳过"] = true
		Global.AddMessageShow(get_parent(), "将会跳过结束剧情！！", 1.5, Vector2(470, 340))
	MemoryClass.main_bc()


func _on_change_bg_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.add_change_bg(BGset, Vector2(0, 0))


func _on_game_set_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	GameSet_ = Global.Add_GameSet_(_menu_content_parent(), Vector2(0, 0))


func _on_game_warn_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.addGameNeedKnow(_menu_content_parent(), Vector2(0, 0))


func CheckTime():
	var error = http_request.request("http://quan.suning.com/getSysTime.do")
	if error != OK:
		push_error("在HTTP请求中发生了一个错误。")
	Times += 1
	if Times >= 15:
		Global.AddMessageShow(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))


func _on_body_received(request, body):
	var time_str = body.get_string_from_utf8()
	if time_str == "":
		print("无法获取时间1！！")
		CheckTime()
		Global.AddMessageShow(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	var utc_time = JSON.parse_string(time_str)
	if utc_time == null:
		print("无法获取时间2！！")
		CheckTime()
		Global.AddMessageShow(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	var TImeUnix = int(utc_time["sysTime2"])
	if TImeUnix == null or str(TImeUnix) == "":
		print("无法获取时间3！！")
		CheckTime()
		Global.AddMessageShow(get_parent(), "获取时间信息失败，网络连接可能存在问题，部分功能将无法使用！！", 1.5, Vector2(470, 340))
		return null
	return TImeUnix


func _on_http_request_request_completed(
	result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray
) -> void:
	if _on_body_received(result, body) != null:
		var abc = str(_on_body_received(result, body)).split()
		var DataList = {
			"year": str(abc[0] + abc[1] + abc[2] + abc[3]),
			"month": str(abc[4] + abc[5]),
			"day": str(abc[6] + abc[7]),
			"hour": str(abc[8] + abc[9]),
			"minute": str(abc[10] + abc[11]),
			"second": str(abc[12] + abc[13]),
		}
		RefreshTime(DataList)


func RefreshTime(DataList):
	var Dic = DataList
	var MyDic = MainSet.set_data["MyTime"]

	if MyDic.size() <= 0:
		return
	if int(Dic["year"]) < int(MyDic["year"]):
		return
	elif int(Dic["year"]) > int(MyDic["year"]):
		print("更新年")
		MainSet.set_data["MyTime"] = DataList
	else:
		if int(Dic["month"]) < int(MyDic["month"]):
			return
		elif int(Dic["month"]) > int(MyDic["month"]):
			print("更新月")
			MainSet.set_data["MyTime"] = DataList
		else:
			if int(Dic["day"]) < int(MyDic["day"]):
				return
			elif int(Dic["day"]) > int(MyDic["day"]):
				print("更新日")
				MainSet.set_data["MyTime"] = DataList
			else:
				return
	MemoryClass.main_bc()


func _on_letter_pressed() -> void:
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.AddLetterForPlayer(_menu_content_parent(), Vector2(0, 0))
