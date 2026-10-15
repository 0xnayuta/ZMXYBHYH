class_name OldUserGlobalAdapter
extends Node

const OldMemoryFacadeScript = preload("res://Script/Compat/OldMemoryFacade.gd")

var memoryClass = OldMemoryFacadeScript.new()
var playerData = PlayerData
var mainSet = MainSet
var mainMusic = MainMusic
var signals = Signals
var allEquipment = AE
var rolePropData = RoleProp
var CurLevel = null
var sxmgAry: Array[bool] = [false, false, false, false, false]
var icon_scale: float = 1.0
var is_joy: bool = true

var cd_path:
	get:
		return Global.cd_path
	set(value):
		var text: = str(value)
		if text == "" or text.begins_with("user://"):
			Global.cd_path = text
		elif text.is_valid_int():
			Global.cd_path = "user://MyAr_%s.json" % text
		else:
			Global.cd_path = text

var Windows_:
	get:
		return Global.Windows_
	set(value):
		Global.Windows_ = value

var FileNum:
	get:
		return Global.FileNum
	set(value):
		Global.FileNum = value

var GameOver:
	get:
		return Global.GameOver
	set(value):
		Global.GameOver = int(value)

func isCheck() -> void :
	pass

func getTimeStr() -> String:
	return Time.get_date_string_from_system()

func gotoMap() -> void :
	Global.change_scene("res://Scene/Main_menu/Map_0.tscn")

func change_secen(target: String) -> void :
	Global.change_scene(target)

func AddLevelInfo(parent, name, position, path):
	return Global.AddLevelInfo(parent, name, position, path)

func AddStar(parent, type):
	return Global.AddStar(parent, type)


func AddHDZM(parent, Parent):
	return Global.AddHDZM(parent, Parent)

func AddMysteryShop(parent, position):
	return Global.AddMysteryShop(parent, position)

func AddRoleButton(parent, my_name, my_father):
	return Global.AddRoleButton(parent, my_name, my_father)

func AddBasicTask_(parent, position):
	return Global.AddBasicTask_(parent, position)

func AddGameAnnouncement(parent, position):
	return Global.AddGameAnnouncement(parent, position)

func AddSomeMonsterHelp(parent, position):
	return Global.AddSomeMonsterHelp(parent, position)

func AddLetterForPlayer(parent, position):
	return Global.AddLetterForPlayer(parent, position)

func Add_GameSet_(parent, position):
	return Global.Add_GameSet_(parent, position)

func AddBasicPellet_(parent, position):
	return Global.AddBasicPellet_(parent, position)

func Addlhhj(parent, position):
	return Global.Addlhhj(parent, position)

func ADDFont_(parent, show_text, font_, font_size, font_color, outline_size, outline_color):
	return Global.ADDFont_(parent, show_text, font_, font_size, font_color, outline_size, outline_color)

func addBGM_(parent, target):
	return Global.addBGM_(parent, target)

func addSound_(parent, target):
	return Global.addSound_(parent, target)

func add_music_set(parent, position):
	return Global.add_music_set(parent, position)

func add_gm_infor(parent, position):
	return Global.add_gm_infor(parent, position)

func addGameNeedKnow(parent, position):
	return Global.addGameNeedKnow(parent, position)

func add_change_bg(parent, position):
	return Global.add_change_bg(parent, position)

func add_set_menu(parent, position):
	return Global.add_set_menu(parent, position)

func add_learn_skill(parent, position):
	return Global.add_learn_skill(parent, position)

func add_magp_infor(parent, position):
	return Global.add_magp_infor(parent, position)

func add_ldl(parent, position):
	return Global.add_ldl(parent, position)

func add_SHOP(parent, position):
	return Global.add_SHOP(parent, position)

func add_choose_text(parent, position, text, _calm_time = 0):
	return Global.add_choose_text(parent, position, text, 0)

func getRes(res_name: String) -> Resource:
	return load(res_name)

func getPngRes(res_name: String) -> Resource:
	return load(res_name)
