extends Node2D











@export var sel_role_mode_array: Array[TextureRect]


@export var sel_role_button_array: Array[TextureButton]

@onready var begin_game_btn: TextureButton = $Bg / BeginGameBtn


var curr_sel_role_id: int = 0

var curr_sel_role_mode: Enums.Sel_Role_Mode_Enum = Enums.Sel_Role_Mode_Enum.单人模式


@export var sel_role_mode_texture_array: Array[Texture]

var Num: int
var RoleNameList = ["孙悟空", "唐三藏", "猪八戒", "沙悟净", "小白龙", "玉兔儿"]
var ProperiesList = ["火", "水", "土", "木", "金", "水"]
var ColorList = ["ff0000", "02ffff", "c16b00", "00ff00", "ffff00", "02ffff"]
var RoleInfo = [
	"齐天大圣孙悟空，机敏聪慧，胆识过人。善用棍法，灵活多变，上手简单。", 
	"金蝉转世唐三藏，佛法无边，普渡众生。武器九环禅杖，爆发，回血极高，攻击冰冻目标。", 
	"天蓬元帅猪八戒，力大无穷，坚韧不拔。武器九齿钉耙，生存能力强，上手简单。", 
	"卷帘大将沙悟净，为人谨慎，朴实无华。使用铲攻，善用猛毒，上限极高。", 
	"玉龙三太子小白龙，智勇双全，刚正不阿。手持长枪，机制多样，操作灵活。", 
]
var ShengCun = [0, 4, 3, 4, 4, 3]
var GongJi = [0, 3, 5, 2, 4, 3]
var MinJie = [0, 5, 3, 4, 3, 4]
var CaoZuo = [0, 3, 4, 3, 4, 5]
var CurrentChoose: int = 1
var PlayerList = ["swk", "tsz"]
func _ready() -> void :

	hide_all_role_mode_texture()

	if MainSet.set_data["LevelHYS"]:
		PlayerList.push_back("zbj")
	if MainSet.set_data["LevelTT"]:
		PlayerList.push_back("swj")
	if MainSet.set_data["XiaoBaiLong"]:
		PlayerList.push_back("xbl")




	begin_game_btn.pressed.connect(_on_begin_game_btn_pressed)






func hide_all_role_mode_texture() -> void :
	if curr_sel_role_mode == Enums.Sel_Role_Mode_Enum.双人模式:

		return

	for node in sel_role_mode_array:
		if node is CanvasItem:
			node.visible = false










































func _on_return_main_menu_pressed() -> void :
	Global.cd_path = ""
	get_tree().change_scene_to_file("res://Scene/Main_menu/Main_Menu.tscn")

func change_to_map():
	match int(PlayerData.player_data["Map_num"]):
		1:
			get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		2:
			if PlayerData.player_data["地府"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_2.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")
		3:
			if PlayerData.player_data["天庭"]:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_3.tscn")
			else:
				get_tree().change_scene_to_file("res://Scene/Main_menu/Map_1.tscn")

func GetTargetCDNum():
	return Global.cd_path.split("r_")[1].split(".")[0]
func get_time():
	var date = Time.get_date_string_from_system()
	var time_ = Time.get_time_string_from_system()
	var last_time = date + " " + time_
	return last_time


func sel_role() -> void :
	if PlayerData.player_data["Myself"] != 0:
		if curr_sel_role_id != PlayerData.player_data["Myself"]:
			Global.AddMessageShow(Global.Windows_, "角色ID不匹配！！", 1.5, Vector2(485, 295))
			return
		Global.AddMessageShow(Global.Windows_, "创建角色失败，该存档已有角色！！", 1.5, Vector2(485, 295))
		return
	if curr_sel_role_id == 0:
		Global.AddMessageShow(Global.Windows_, "请先选择一位角色！！", 1.5, Vector2(485, 295))
		return
	if int(GetTargetCDNum()) <= 6:
		MainSet.set_data["time" + str(Num)] = get_time()
	else:
		MainSet.set_data["其他存档"][str(GetTargetCDNum())]["time"] = get_time()


	hide_all_role_mode_texture()

	match curr_sel_role_mode:
		Enums.Sel_Role_Mode_Enum.单人模式:
			sel_role_mode_array[curr_sel_role_id - 1].texture = sel_role_mode_texture_array[0]
			pass
		Enums.Sel_Role_Mode_Enum.双人模式:

			pass
	sel_role_mode_array[curr_sel_role_id - 1].visible = true



func _on_sel_role_1_btn_pressed() -> void :
	curr_sel_role_id = 1
	sel_role()
	pass


func _on_sel_role_2_btn_pressed() -> void :
	curr_sel_role_id = 2
	sel_role()
	pass


func _on_sel_role_3_btn_pressed() -> void :
	curr_sel_role_id = 3
	sel_role()
	pass


func _on_sel_role_4_btn_pressed() -> void :
	curr_sel_role_id = 4
	sel_role()
	pass


func _on_sel_role_5_btn_pressed() -> void :
	curr_sel_role_id = 5
	sel_role()
	pass


func _on_sel_role_6_btn_pressed() -> void :
	curr_sel_role_id = 6
	sel_role()
	pass


func _on_begin_game_btn_pressed() -> void :
	if curr_sel_role_id == 0:
		Global.AddMessageShow(Global.Windows_, "请先选择一位角色！！", 1.5, Vector2(485, 295))

		return



	if curr_sel_role_id == 6:
		Global.AddMessageShow(Global.Windows_, "后续版本解锁新角色！！", 1.5, Vector2(485, 295))

		return


	MemoryClass.main_bc()
	PlayerData.player_data["Myself"] = int(curr_sel_role_id)
	MemoryClass.保存游戏(Global.cd_path)
	change_to_map()

	pass
