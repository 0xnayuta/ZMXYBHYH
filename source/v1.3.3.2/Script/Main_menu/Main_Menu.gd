extends Node2D
class_name MainMenu
var abx: TextureButton
@onready var ar_infer: Node2D = $ar_infer
@onready var BGset: Node2D = $BGset
@onready var begin_game = $ButtonList / Begin_game
@onready var Music_set = $Music_set
@onready var music: Button = $ButtonList / music
@onready var tiaoguo: Button = $ButtonList / tiaoguo
@onready var BackGround = $background
@onready var name_: Label = $background / name
@onready var Hide_1 = $background / Hide
@onready var Hide_2 = $background / Hide2
@onready var name_2: Label = $background / name / name2

var my_music
var is_playing = false
var cd_jm
var message_box
var music_jm
var GameSet_: GameSet

func _ready() -> void :
	print(Time.get_time_string_from_system(false))
	print(Time.get_time_string_from_system(true))
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
		Global.addGameNeedKnow(self, Vector2(0, 0))
		pass
func _physics_process(_delta: float) -> void :
	if MainSet.set_data["剧情跳过"]:
		tiaoguo.text = "显示剧情"
	else:
		tiaoguo.text = "跳过剧情"
	match int(MainSet.set_data["MainMenuBG"]):
		1:
			name_2.text = "八荒湮隳篇·力战七大魔王"
			Hide_1.visible = false
			Hide_2.visible = false
			BackGround.texture = load("res://Art/MainGame/Bg1.png")
		2:
			name_2.text = "八荒湮隳篇·勇斗十殿阎罗"
			Hide_1.visible = false
			Hide_2.visible = false
			BackGround.texture = load("res://Art/MainGame/Bg2.png")
		3:
			name_2.text = "八荒湮隳篇·智取十万天兵"
			Hide_1.visible = false
			Hide_2.visible = false
			BackGround.texture = load("res://Art/MainGame/Bg3.png")
	RoleProp.ws_value = 0
	if Music_set.get_child_count() != 0:
		music.disabled = true
		if music_jm != null:
			if music_jm.is_change:
				MainMusic.ADDMusic()
				music_jm.is_change = false
	else:
		music.disabled = false
	if GameSet_ != null:
		if GameSet_.MusicIsChange:
			MainMusic.ADDMusic()
			GameSet_.MusicIsChange = false

func _on_begin_game_pressed() -> void :

	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")

	if ar_infer.get_child_count() == 0:
		cd_jm = Global.add_cd_jm(ar_infer, Vector2(0, 0))



func _on_music_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	music_jm = Global.add_music_set(Music_set, Vector2(0, 0))



func _on_gmae_help_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.add_gm_infor(self, Vector2(0, 0))


func _on_tiaoguo_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	if MainSet.set_data["剧情跳过"]:
		MainSet.set_data["剧情跳过"] = false
		Global.AddMessageShow(get_parent(), "将不会跳过结束剧情！！", 1.5, Vector2(470, 340))
	else:
		MainSet.set_data["剧情跳过"] = true
		Global.AddMessageShow(get_parent(), "将会跳过结束剧情！！", 1.5, Vector2(470, 340))
	MemoryClass.main_bc()

func _on_change_bg_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.add_change_bg(BGset, Vector2(0, 0))


func _on_game_set_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	GameSet_ = Global.Add_GameSet_(self, Vector2(0, 0))


func _on_game_warn_pressed() -> void :
	Global.addBGM_(self, "res://Music/MainSceneMusic/2_SD_xz.mp3")
	Global.addGameNeedKnow(self, Vector2(0, 0))
